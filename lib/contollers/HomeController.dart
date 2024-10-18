import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readswap/old/firebase/auth.dart';

class HomeController extends GetxController {
    var bestBooks = <DocumentSnapshot>[].obs;
  var cacheBestBooks = <DocumentSnapshot>[];
  var isFirstLoad = true.obs; // Sayfaya ilk defa mı giriliyor kontrolü
  var recommendedBooks = <DocumentSnapshot>[].obs;
  var booksByCoins = <DocumentSnapshot>[].obs;
  var recentBooks = <DocumentSnapshot>[].obs; // New recent books list
  var userCoinBalance = 0.obs;
  var userName = ''.obs;

  
  @override
  void onInit() {
    super.onInit();
    _fetchInitialData(); // Load initial data
    _listenToBookUpdates(); // Listen to Firestore updates
  }

  Future<void> _fetchInitialData() async {
    if (isFirstLoad.value) { // Eğer sayfa ilk defa açılıyorsa verileri yükle
      bestBooks.value = await _fetchBestBooks();
      recommendedBooks.value = await _fetchBestBooks(); 
      cacheBestBooks = bestBooks; // Cache'leyelim
      isFirstLoad.value = false; // Artık sayfa ilk defa yüklenmiyor
    } else {
      bestBooks.value = cacheBestBooks; // Cache'den kitapları getir
    }
  }



    void _listenToBookUpdates() {
    FirebaseFirestore.instance
        .collection('Books')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      if (_newBooksAdded(snapshot.docs)) { // Eğer yeni kitaplar eklenmişse
        bestBooks.value = snapshot.docs;
        cacheBestBooks = bestBooks; // Cache'i güncelle
      }
    });
  }


  bool _newBooksAdded(List<DocumentSnapshot> newBooks) {
    // Kitaplar listesinde fark var mı kontrol et
    return newBooks.length != cacheBestBooks.length;
  }

  

Future<List<DocumentSnapshot>> _fetchBestBooks() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Books')
        .orderBy('CreatedAt', descending: true)
        .limit(2)
        .where('isActive', isEqualTo: true)
        .get();
    return querySnapshot.docs;
  }


  Future<List<DocumentSnapshot>> _fetchRecentBooks() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Books')
        .orderBy('CreatedAt', descending: true)
        .limit(10)
        .where('isActive', isEqualTo: true)
        .get();
    return querySnapshot.docs;
  }

  // Future<List<DocumentSnapshot>> _fetchRecommendedBooks() async {
  //   List<String> selectedCategories = await _fetchSelectedCategories();
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('Books')
  //       .where('CategoryId', whereIn: selectedCategories)
  //       .where('isActive', isEqualTo: true)
  //       .get();
  //   return querySnapshot.docs;
  // }
  // Future<int> _fetchUserCoinBalance() async {
  //   var currentUser = FirebaseAuth.instance.currentUser;
  //   var userDoc = await FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(currentUser?.uid)
  //       .get();
  //   return (userDoc.data()?['coins'] ?? 0).toInt();
  // }

  // Future<List<String>> _fetchSelectedCategories() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(user?.uid)
  //       .get();
  //   return List<String>.from(userDoc['selectedCategories'] ?? []);
  // }

  // Future<List<DocumentSnapshot>> _fetchBooksWithUserCoins(int userCoins) async {
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('Books')
  //       .where('isActive', isEqualTo: true)
  //       .get();

  //   return querySnapshot.docs.where((doc) {
  //     double? bookPrice = double.tryParse(doc['BookPrice'] ?? '0');
  //     return bookPrice != null && bookPrice <= userCoins;
  //   }).toList();
  // }
}
