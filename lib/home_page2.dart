import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readswap/book_details.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:readswap/category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readswap/firebase/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DocumentSnapshot>> bestBooksFuture;
  late Future<String?> userNameFuture;
  late Future<List<String>> selectedCategoriesFuture;
  late Future<int> userCoinBalanceFuture; // New future for user coin balance
  late Future<List<DocumentSnapshot>>
      booksByCoinsFuture; // New future for books user can afford

  @override
  void initState() {
    super.initState();
    bestBooksFuture = _fetchBestBooks();
    userNameFuture = Auth().getUsername(); // Fetch logged-in user's name
    selectedCategoriesFuture =
        _fetchSelectedCategories(); // Fetch user's selected categories
    userCoinBalanceFuture =
        _fetchUserCoinBalance(); // Fetch user's coin balance
    booksByCoinsFuture = userCoinBalanceFuture.then((coins) =>
        _fetchBooksWithUserCoins(coins)); // Fetch books based on coins
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(),
            // Search Bar
            _buildSearchBar(),
            // Categories Section
            _buildCategoriesSection(),
            // Best Books Section
            _buildBestBooksSection(),
            // Recommended Books Section
            _buildRecommendedBooksSection(),
            // Books based on Coins Section
            _buildBooksWithUserCoinsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, right: 20, bottom: 20, left: 20),
      child: FutureBuilder<String?>(
        future: userNameFuture,
        builder: (context, snapshot) {
          String userName = snapshot.data ?? 'Kullanıcı';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Merhaba, $userName!",
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF86BC96),
                ),
              ),
              const Text(
                "Her yerde aradığın kitap burada!",
                style: TextStyle(
                  color: Color(0xFF6C6C6C),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Kitap veya kategori ara...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        ),
        cursorColor: const Color(0xFF787878),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Kategoriler"),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'assets/Category$index.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestBooksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Son Eklenenler"),
          SizedBox(
            height: 400,
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: bestBooksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingWidget();
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Data'));
                }

                List<DocumentSnapshot> bestBooks = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bestBooks.length,
                  itemBuilder: (context, index) {
                    var book = bestBooks[index].data() as Map<String, dynamic>;
                    return _buildBookCard(book, bestBooks[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedBooksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Sizin İçin Önerilenler"),
          FutureBuilder<List<String>>(
            future: selectedCategoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              }
              if (snapshot.hasError) {
                return _buildErrorWidget('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No selected categories found.'));
              }

              List<String> selectedCategories = snapshot.data!;
              return FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchRecommendedBooks(selectedCategories),
                builder: (context, bookSnapshot) {
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }
                  if (bookSnapshot.hasError) {
                    return _buildErrorWidget('Error: ${bookSnapshot.error}');
                  }
                  if (!bookSnapshot.hasData || bookSnapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No recommended books found.'));
                  }

                  List<DocumentSnapshot> recommendedBooks = bookSnapshot.data!;
                  return _buildBookList(recommendedBooks);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBooksWithUserCoinsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Coinin İle Alabileceklerin"),
          FutureBuilder<List<DocumentSnapshot>>(
            future: booksByCoinsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              }
              if (snapshot.hasError) {
                return _buildErrorWidget('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No books available for your coins.'));
              }

              List<DocumentSnapshot> booksByCoins = snapshot.data!;
              return _buildBookList(booksByCoins);
            },
          ),
        ],
      ),
    );
  }

  // Helper method for building a book card
  Widget _buildBookCard(Map<String, dynamic> book, String bookId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetails(bookId: bookId),
          ),
        );
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book['BookImage'] ?? '',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book['BookTitle'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book['UserName'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(List<DocumentSnapshot> books) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          var book = books[index].data() as Map<String, dynamic>;
          return _buildBookCard(book, books[index].id);
        },
      ),
    );
  }

  Widget _buildRowText(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for loading, error, and fetching data
  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text(error),
    );
  }

  Future<List<DocumentSnapshot>> _fetchBestBooks() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    return querySnapshot.docs;
  }

  Future<int> _fetchUserCoinBalance() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    return userDoc.data()?['coinBalance'] ?? 0;
  }

  Future<List<DocumentSnapshot>> _fetchBooksWithUserCoins(int userCoins) async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('books')
        .where('coin', isLessThanOrEqualTo: userCoins)
        .get();
    return querySnapshot.docs;
  }

  Future<List<String>> _fetchSelectedCategories() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    return List<String>.from(userDoc.data()?['selectedCategories'] ?? []);
  }

  Future<List<DocumentSnapshot>> _fetchRecommendedBooks(
      List<String> selectedCategories) async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('books')
        .where('category', whereIn: selectedCategories)
        .get();
    return querySnapshot.docs;
  }
}
