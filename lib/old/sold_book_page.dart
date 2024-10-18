import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:readswap/old/sellerDetailsPage.dart';

class SoldBooksPage extends StatefulWidget {
  @override
  _SoldBooksPageState createState() => _SoldBooksPageState();
}

class _SoldBooksPageState extends State<SoldBooksPage> {
  late Future<List<Map<String, dynamic>>> _soldBooksFuture;

  @override
  void initState() {
    super.initState();
    _soldBooksFuture = _fetchSoldBooks();
  }

  Future<List<Map<String, dynamic>>> _fetchSoldBooks() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .get();

      List<Map<String, dynamic>> soldBooks = [];

      for (var doc in querySnapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;

        if (orderData['Book'] is DocumentReference) {
          DocumentReference bookRef = orderData['Book'];
          DocumentSnapshot bookSnapshot = await bookRef.get();

          if (bookSnapshot.exists) {
            var bookData = bookSnapshot.data() as Map<String, dynamic>;

            // UserId'nin DocumentReference olup olmadığını kontrol et
            if (bookData['UserId'] is DocumentReference) {
              DocumentReference bookUserIdRef =
                  bookData['UserId']; // kitap içerisindeki userıd 7hg

              // bookUserIdRef'in yolundan UserId'yi ayıkla
              if (bookUserIdRef.path.contains('/')) {
                String bookUserId = bookUserIdRef.path.split('/').last;
                print('Book UserId: $bookUserId');
                print('Current UserId: $userId');

                // Eğer bookUserId bizim userId'miz ile eşleşiyorsa, ekleyelim
                if (bookUserId.isNotEmpty) {
                  soldBooks.add({
                    'orderId': doc.id,
                    'orderDate': orderData['OrderDate'],
                    'bookTitle': bookData['BookTitle'],
                    'bookImage': bookData['BookImage'],
                  });
                } else {
                  print('Not Added Book: ${bookData['BookTitle']}');
                }
              }
            }
          }
        }
      }

      return soldBooks;
    } catch (e) {
      print('Error fetching sold books: $e');
      return [];
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satışlarım'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _soldBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Sold Books'));
          }

          List<Map<String, dynamic>> soldBooks = snapshot.data!;
          return ListView.builder(
            itemCount: soldBooks.length,
            itemBuilder: (context, index) {
              var book = soldBooks[index];
              return ListTile(
                leading: FutureBuilder<String>(
                  future: _getDownloadUrl(book['bookImage']),
                  builder: (context, urlSnapshot) {
                    if (urlSnapshot.connectionState ==
                        ConnectionState.waiting) {
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
                title: Text(book['bookTitle']),
                subtitle: Text('Order Date: ${book['orderDate'].toDate()}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SellerOrderDetailPage(orderId: book['orderId']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
