import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  var addressList = <Map<String, dynamic>>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  void fetchAddresses() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var snapshot = await _firestore
          .collection('Address')
          .where('UserId', isEqualTo: user.uid)
          .get();
      var addresses = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      addressList.assignAll(addresses);
    }
  }

  void addAddress(Map<String, dynamic> addressData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      addressData['UserId'] = user.uid;
      await _firestore.collection('Address').add(addressData);
      fetchAddresses();
    }
  }

  void updateAddress(String id, Map<String, dynamic> addressData) async {
    await _firestore.collection('Address').doc(id).update(addressData);
    fetchAddresses();
  }
}
