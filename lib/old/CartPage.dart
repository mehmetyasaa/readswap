import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sepet Detayları'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Cart')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Sepetiniz boş.'));
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var item = cartItems[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Books')
                    .doc(item['bookId'])
                    .get(),
                builder: (context, bookSnapshot) {
                  if (bookSnapshot.hasError) {
                    return Center(child: Text('Kitap verisi alınamadı: ${bookSnapshot.error}'));
                  }
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
                    return Center(child: Text('Kitap bulunamadı.'));
                  }

                  var bookData = bookSnapshot.data!.data() as Map<String, dynamic>;
                  var userRef = bookData['UserId'] as DocumentReference?;

                  return FutureBuilder<DocumentSnapshot>(
                    future: userRef?.get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.hasError) {
                        return Center(child: Text('Kullanıcı verisi alınamadı: ${userSnapshot.error}'));
                      }
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      String userName = 'Bilinmiyor';
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        userName = userData['username'] ?? 'Bilinmiyor'; // Adjust this key based on your user document
                      }

                      return CartItemWidget(
                        bookData: bookData,
                        userName: userName,
                        documentSnapshot: item,
                      );
                    },
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

class CartItemWidget extends StatelessWidget {
  final Map<String, dynamic> bookData;
  final String userName;
  final DocumentSnapshot documentSnapshot;

  CartItemWidget({required this.bookData, required this.userName, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bookData['BookImage'] != null && bookData['BookImage'].isNotEmpty)
            Image.network(
              bookData['BookImage'],
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, size: 80, color: Colors.grey);
              },
            )
          else
            Icon(Icons.image, size: 80, color: Colors.grey),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookData['BookTitle'] ?? 'Başlık Yok',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Satıcı: $userName',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 5),
                Text(
                  '\$${bookData['BookPrice'] ?? '0'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        // Ürün miktarını azaltma işlemi yapılabilir
                      },
                    ),
                  //  Text('${documentSnapshot['BookStatus'] ?? '0'}'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Cart')
                    .doc(documentSnapshot.id)  // Use the document ID to delete the specific document
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ürün sepetten silindi.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Silme işlemi başarısız: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
