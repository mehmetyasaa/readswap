// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';

// class AddressController extends GetxController {
//   var addressList = <Map<String, dynamic>>[].obs;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchAddresses();
//   }

//   void fetchAddresses() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       var snapshot = await _firestore
//           .collection('Address')
//           .where('UserId', isEqualTo: user.uid)
//           .get();
//       var addresses = snapshot.docs.map((doc) {
//         var data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//       addressList.assignAll(addresses);
//     }
//   }

//   void addAddress(Map<String, dynamic> addressData) async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       addressData['UserId'] = user.uid;
//       await _firestore.collection('Address').add(addressData);
//       fetchAddresses();
//     }
//   }

//   void updateAddress(String id, Map<String, dynamic> addressData) async {
//     await _firestore.collection('Address').doc(id).update(addressData);
//     fetchAddresses();
//   }
// }

// class PurchaseController extends StatefulWidget {
//   final String bookId;
//   final String sellerId;
//   final double price;

//   PurchaseController({
//     required this.bookId,
//     required this.sellerId,
//     required this.price,
//   });

//   @override
//   _PurchaseControllerState createState() => _PurchaseControllerState();
// }

// class _PurchaseControllerState extends State<PurchaseController> {
//   final AddressController _addressController = Get.put(AddressController());
//   String? selectedAddressId;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _purchaseBook() async {
//     if (selectedAddressId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lütfen bir adres seçin')),
//       );
//       return;
//     }

//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(userId)
//           .get();
//       DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(widget.sellerId)
//           .get();

//       if (userSnapshot.exists && sellerSnapshot.exists) {
//         Map<String, dynamic>? userData =
//             userSnapshot.data() as Map<String, dynamic>?;
//         Map<String, dynamic>? sellerData =
//             sellerSnapshot.data() as Map<String, dynamic>?;

//         if (userData != null && userData.containsKey('coins')) {
//           double userCoins = userData['coins']?.toDouble() ?? 0.0;
//           double sellerCoins = sellerData!['coins']?.toDouble() ?? 0.0;

//           if (userCoins >= widget.price) {
//             // Coinler yeterliyse, satın alma işlemini gerçekleştir
//             await FirebaseFirestore.instance
//                 .runTransaction((transaction) async {
//               DocumentReference bookRef = FirebaseFirestore.instance
//                   .collection('Books')
//                   .doc(widget.bookId);
//               DocumentReference orderRef =
//                   FirebaseFirestore.instance.collection('Orders').doc();
//               DocumentReference userRef =
//                   FirebaseFirestore.instance.collection('Users').doc(userId);
//               DocumentReference sellerRef = FirebaseFirestore.instance
//                   .collection('Users')
//                   .doc(widget.sellerId);
//               DocumentReference addressRef = FirebaseFirestore.instance
//                   .collection('Address')
//                   .doc(selectedAddressId);

//               transaction.update(userRef, {'coins': userCoins - widget.price});
//               transaction
//                   .update(sellerRef, {'coins': sellerCoins + widget.price});
//               transaction.set(orderRef, {
//                 'Address': addressRef,
//                 'Book': bookRef,
//                 'OrderDate': FieldValue.serverTimestamp(),
//                 'User': userRef,
//               });

//               // Satıcıya ödeme ekleme işlemi burada yapılabilir
//             });

//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Satın alma başarılı')),
//             );
//           } else {
//             // Yetersiz bakiye durumu
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Yetersiz bakiye')),
//             );
//           }
//         } else {
//           // Kullanıcının coins alanı yoksa
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Coins bilgisi bulunamadı')),
//           );
//         }
//       } else {
//         // Kullanıcı veya satıcı belgesi yoksa
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Kullanıcı veya satıcı bulunamadı')),
//         );
//       }
//     } catch (e) {
//       print('Error purchasing book: $e');
//     }
//   }

//   Future<void> _addNewAddress() async {
//     final TextEditingController _titleController = TextEditingController();
//     final TextEditingController _cityController = TextEditingController();
//     final TextEditingController _codeController = TextEditingController();
//     final TextEditingController _line1Controller = TextEditingController();
//     final TextEditingController _line2Controller = TextEditingController();
//     final TextEditingController _phoneController = TextEditingController();
//     final TextEditingController _stateController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Yeni Adres Ekle'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _titleController,
//                 decoration: InputDecoration(labelText: 'Başlık'),
//               ),
//               TextField(
//                 controller: _cityController,
//                 decoration: InputDecoration(labelText: 'Şehir'),
//               ),
//               TextField(
//                 controller: _codeController,
//                 decoration: InputDecoration(labelText: 'Posta Kodu'),
//               ),
//               TextField(
//                 controller: _line1Controller,
//                 decoration: InputDecoration(labelText: 'Adres Satırı 1'),
//               ),
//               TextField(
//                 controller: _line2Controller,
//                 decoration: InputDecoration(labelText: 'Adres Satırı 2'),
//               ),
//               TextField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(labelText: 'Telefon'),
//               ),
//               TextField(
//                 controller: _stateController,
//                 decoration: InputDecoration(labelText: 'Eyalet/İl'),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('İptal'),
//           ),
//           TextButton(
//             onPressed: () {
//               var newAddress = {
//                 'AddressTitle': _titleController.text,
//                 'AddressCity': _cityController.text,
//                 'AddressCode': _codeController.text,
//                 'AddressLine1': _line1Controller.text,
//                 'AddressLine2': _line2Controller.text,
//                 'AddressPhone': _phoneController.text,
//                 'AddressState': _stateController.text,
//               };
//               _addressController.addAddress(newAddress);
//               Navigator.of(context).pop();
//             },
//             child: Text('Ekle'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Satın Alma İşlemi'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Obx(() {
//               return DropdownButton<String>(
//                 hint: Text('Adres Seçin'),
//                 value: selectedAddressId,
//                 items: _addressController.addressList.map((address) {
//                   return DropdownMenuItem<String>(
//                     value: address['id'],
//                     child: Text(address['AddressTitle']),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedAddressId = value;
//                   });
//                 },
//               );
//             }),
//             ElevatedButton(
//               onPressed: _addNewAddress,
//               child: Text('Yeni Adres Ekle'),
//             ),
//             ElevatedButton(
//               onPressed: _purchaseBook,
//               child: Text('Satın Al'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
