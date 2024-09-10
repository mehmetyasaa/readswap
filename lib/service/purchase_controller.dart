import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:readswap/service/address_controller.dart';

class CheckoutPage extends StatefulWidget {
  final String bookId;
  final String sellerId;
  final double price;
  final double shippingCost;

  CheckoutPage({
    required this.bookId,
    required this.sellerId,
    required this.price,
    required this.shippingCost,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedAddressId;
  final AddressController _addressController = Get.put(AddressController());

  @override
  void initState() {
    super.initState();
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching download URL: $e');
      return '';
    }
  }

  Future<void> _purchaseBook() async {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir adres seçin veya ekleyin')),
      );
      return;
    }

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.sellerId)
          .get();

      if (userSnapshot.exists && sellerSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        Map<String, dynamic>? sellerData =
            sellerSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('coins')) {
          double userCoins = userData['coins']?.toDouble() ?? 0.0;
          double sellerCoins = sellerData!['coins']?.toDouble() ?? 0.0;
          double totalCost = widget.price + widget.shippingCost;

          if (userCoins >= totalCost) {
            await FirebaseFirestore.instance
                .runTransaction((transaction) async {
              DocumentReference bookRef = FirebaseFirestore.instance
                  .collection('Books')
                  .doc(widget.bookId);
              DocumentReference orderRef =
                  FirebaseFirestore.instance.collection('Orders').doc();
              DocumentReference userRef =
                  FirebaseFirestore.instance.collection('Users').doc(userId);
              DocumentReference sellerRef = FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.sellerId);
              DocumentReference addressRef = FirebaseFirestore.instance
                  .collection('Address')
                  .doc(selectedAddressId);

              transaction.update(userRef, {'coins': userCoins - totalCost});
              transaction
                  .update(sellerRef, {'coins': sellerCoins + widget.price});
              transaction.set(orderRef, {
                'Address': addressRef,
                'Book': bookRef,
                'OrderDate': FieldValue.serverTimestamp(),
                'User': userRef,
                'ShippingCost': widget.shippingCost,
                'TotalCost': totalCost,
                'OrderStatus': 'received',
              });

              // Update book status to inactive
              transaction.update(bookRef, {'isActive': false});
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Satın alma başarılı')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Yetersiz bakiye')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coins bilgisi bulunamadı')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı veya satıcı bulunamadı')),
        );
      }
    } catch (e) {
      print('Error purchasing book: $e');
    }
  }

  Widget _buildAddressContainer() {
    return Container(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Address')
            .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var addresses = snapshot.data!.docs;
          if (addresses.isEmpty) {
            return Center(child: Text('Adres bulunamadı. Lütfen ekleyin.'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              var address = addresses[index];
              return Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedAddressId == address.id
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAddressId = address.id;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address['AddressTitle'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.0),
                      Text(
                          '${address['AddressLine1']}, ${address['AddressCity']}, ${address['AddressState']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addNewAddress() async {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _cityController = TextEditingController();
    final TextEditingController _codeController = TextEditingController();
    final TextEditingController _line1Controller = TextEditingController();
    final TextEditingController _line2Controller = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _stateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Adres Ekle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Şehir'),
              ),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Posta Kodu'),
              ),
              TextField(
                controller: _line1Controller,
                decoration: InputDecoration(labelText: 'Adres Satırı 1'),
              ),
              TextField(
                controller: _line2Controller,
                decoration: InputDecoration(labelText: 'Adres Satırı 2'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefon'),
              ),
              TextField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'Eyalet/İl'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              var newAddress = {
                'AddressTitle': _titleController.text,
                'AddressCity': _cityController.text,
                'AddressCode': _codeController.text,
                'AddressLine1': _line1Controller.text,
                'AddressLine2': _line2Controller.text,
                'AddressPhone': _phoneController.text,
                'AddressState': _stateController.text,
              };
              _addressController.addAddress(newAddress);
              Navigator.of(context).pop();
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Books')
          .doc(widget.bookId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var bookData = snapshot.data!.data() as Map<String, dynamic>;
        return ListTile(
          leading: FutureBuilder<String>(
            future: _getDownloadUrl(bookData['BookImage'] ?? "ürün resmi"),
            builder: (context, urlSnapshot) {
              if (urlSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (urlSnapshot.hasError ||
                  !urlSnapshot.hasData ||
                  urlSnapshot.data!.isEmpty) {
                return Icon(Icons.error);
              }

              String imageUrl = urlSnapshot.data!;
              return Image.network(imageUrl,
                  width: 50, height: 50, fit: BoxFit.cover);
            },
          ),
          title: Text(bookData['BookTitle'] ?? 'Ürün Başlığı'),
          subtitle: Text(bookData['BookDescription'] ?? 'Ürün Açıklaması'),
          trailing: Text('${widget.price} coin'),
        );
      },
    );
  }

  Widget _buildTotalCost() {
    return Column(
      children: [
        ListTile(
          title: Text('Ürün Fiyatı'),
          trailing: Text('${widget.price} coin'),
        ),
        ListTile(
          title: Text('Kargo Ücreti'),
          trailing: Text('${widget.shippingCost} coin'),
        ),
        ListTile(
          title: Text('Toplam'),
          trailing: Text('${widget.price + widget.shippingCost} coin'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Adresler', style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _addNewAddress();
                    },
                  ),
                ],
              ),
            ),
            _buildAddressContainer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Alınan Ürün',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildProductInfo(),
            Divider(),
            _buildTotalCost(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _purchaseBook,
                child: Text('Satın Al'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
