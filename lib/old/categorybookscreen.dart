import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readswap/old/book_details.dart'; // Ensure this import is correct for your project

class CategoryBooksScreen extends StatelessWidget {
  final String category;

  const CategoryBooksScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Books'),
        backgroundColor: const Color.fromARGB(185, 2, 201, 108),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Books')
            .where('CategoryId', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books found in this category'));
          }

          final bookDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: bookDocs.length,
            itemBuilder: (context, index) {
              final bookData = bookDocs[index].data() as Map<String, dynamic>;
              final bookId = bookDocs[index].id; // Get the document ID

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetails(bookId: bookId),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: bookData['BookImage'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              bookData['BookImage']!,
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.book, size: 60),
                    title: Text(
                      bookData['BookTitle'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      bookData['Author'] ?? 'Unknown Author',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetails(bookId: bookId),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
