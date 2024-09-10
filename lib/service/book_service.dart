import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readswap/firebase/auth.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(
      String bookDescription,
      String bookImage,
      String bookIsbn,
      String bookPrice,
      String bookStatus,
      String bookTitle,
      String bookWriter,
      String categoryId,
      {bool isActive = true}) async {
    try {
      // Get the current user's UID
      String userId = Auth().currentUser!.uid;

      // Create a reference to the user's document
      DocumentReference userRef = _firestore.collection('Users').doc(userId);
      await _firestore.collection('Books').add({
        'BookDescription': bookDescription,
        'BookImage': bookImage,
        'BookIsbn': bookIsbn,
        'BookPrice': bookPrice,
        'BookStatus': bookStatus,
        'BookTitle': bookTitle,
        'BookWriter': bookWriter,
        'CategoryId': categoryId,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UserId': userRef,
        'isActive': isActive,
      });
    } catch (e) {
      print('Error creating book: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Books')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'BookDescription': doc['BookDescription'],
                'BookImage': doc['BookImage'],
                'BookIsbn': doc['BookIsbn'],
                'BookPrice': doc['BookPrice'],
                'BookStatus': doc['BookStatus'],
                'BookTitle': doc['BookTitle'],
                'BookWriter': doc['BookWriter'],
                'CategoryId': doc['CategoryId'],
                'CreatedAt': doc['CreatedAt'],
                'isActive': doc['isActive'],
              })
          .toList();
    } catch (e) {
      print('Error getting books: $e');
      throw e;
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('Books').doc(id).update(data);
    } catch (e) {
      print('Error updating book: $e');
      throw e;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _firestore.collection('Books').doc(id).delete();
    } catch (e) {
      print('Error deleting book: $e');
      throw e;
    }
  }
}
