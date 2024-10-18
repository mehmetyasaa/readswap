import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readswap/old/firebase/auth.dart';

class HomeController extends GetxController {
  var bestBooks = <DocumentSnapshot>[].obs;
  var recommendedBooks = <DocumentSnapshot>[].obs;
  var booksByCoins = <DocumentSnapshot>[].obs;
  var userCoinBalance = 0.obs;
  var userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData(); // Verileri ilk olarak yükle
    _listenToBookUpdates(); // Firestore'daki güncellemeleri dinle
  }

  // Verilerin ilk yüklenmesini sağlar
  Future<void> _fetchInitialData() async {
    userName.value = await Auth().getUsername() ?? 'Kullanıcı';
    userCoinBalance.value = await _fetchUserCoinBalance();
    bestBooks.value = await _fetchBestBooks();
    recommendedBooks.value = await _fetchRecommendedBooks();
    booksByCoins.value = await _fetchBooksWithUserCoins(userCoinBalance.value);
  }

  // Firestore'daki kitap güncellemelerini dinler
  void _listenToBookUpdates() {
    FirebaseFirestore.instance.collection('Books').snapshots().listen((snapshot) {
      bestBooks.value = snapshot.docs; // Verileri günceller
    });
  }

  Future<List<DocumentSnapshot>> _fetchBestBooks() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Books')
        .orderBy('CreatedAt', descending: true)
        .limit(10)
        .where('isActive', isEqualTo: true)
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _fetchRecommendedBooks() async {
    List<String> selectedCategories = await _fetchSelectedCategories();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Books')
        .where('CategoryId', whereIn: selectedCategories)
        .where('isActive', isEqualTo: true)
        .get();
    return querySnapshot.docs;
  }

  Future<int> _fetchUserCoinBalance() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser?.uid)
        .get();
    return (userDoc.data()?['coins'] ?? 0).toInt();
  }

  Future<List<String>> _fetchSelectedCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user?.uid)
        .get();
    return List<String>.from(userDoc['selectedCategories'] ?? []);
  }

  Future<List<DocumentSnapshot>> _fetchBooksWithUserCoins(int userCoins) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Books')
        .where('isActive', isEqualTo: true)
        .get();

    return querySnapshot.docs.where((doc) {
      double? bookPrice = double.tryParse(doc['BookPrice'] ?? '0');
      return bookPrice != null && bookPrice <= userCoins;
    }).toList();
  }
}
