import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetails extends StatelessWidget {
  final String bookId;

  ProductDetails({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Detayları'),
        backgroundColor: const Color.fromARGB(255, 122, 156, 124),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Books').doc(bookId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Kitap bulunamadı.'));
          }

          final book = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: book['BookImage'] != null
                      ? Image.network(book['BookImage'], width: 150, height: 200, fit: BoxFit.cover)
                      : Icon(Icons.book, size: 150),
                ),
                SizedBox(height: 16),
                Text(
                  book['BookTitle'] ?? 'Bilinmeyen Kitap',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Yazar: ${book['BookWriter'] ?? 'Bilinmeyen Yazar'}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Text(
                  'Açıklama:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  book['BookDescription'] ?? 'Açıklama mevcut değil.',
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                Text(
                  'Fiyat: ${book['BookPrice'] ?? 'Bilinmiyor'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
