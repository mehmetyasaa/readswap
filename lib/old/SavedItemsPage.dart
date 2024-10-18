import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readswap/old/book_details.dart'; // Ensure this import is correct

class SavedItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Giriş yapmadınız.', style: TextStyle(fontSize: 18, color: Colors.red)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kaydedilenler'),
        backgroundColor: const Color.fromARGB(255, 122, 156, 124),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}', style: TextStyle(fontSize: 18, color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz kaydedilen ürün yok.', style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final bookId = doc['bookId'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Books').doc(bookId).get(),
                builder: (context, bookSnapshot) {
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (bookSnapshot.hasError) {
                    return Center(child: Text('Hata: ${bookSnapshot.error}', style: TextStyle(fontSize: 18, color: Colors.red)));
                  }

                  if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
                    return SizedBox.shrink();
                  }

                  final book = bookSnapshot.data!.data() as Map<String, dynamic>;
                  return Dismissible(
                    key: Key(bookId),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white, size: 32),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white, size: 32),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Silme Onayı'),
                          content: Text('Bu ürünü kaydedilenler listesinden silmek istiyor musunuz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Evet'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Hayır'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      // Remove from user's Favorites collection
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .collection('Favorites')
                          .doc(doc.id)
                          .delete();
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: book['BookImage'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(book['BookImage'], width: 60, fit: BoxFit.cover),
                              )
                            : Icon(Icons.book, size: 60, color: Colors.grey),
                        title: Text(
                          book['BookTitle'] ?? 'Bilinmeyen Kitap',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(book['BookWriter'] ?? 'Bilinmeyen Yazar', style: TextStyle(fontSize: 14)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetails(bookId: bookId),
                            ),
                          );
                        },
                      ),
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
