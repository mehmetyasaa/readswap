import 'package:cloud_firestore/cloud_firestore.dart';

class ForumController {
  final forumCollection = FirebaseFirestore.instance.collection("Forums");

  Future<void> createForum({
    required String title,
    required String description,
    required String createdBy,
  }) async {
    await forumCollection.add({
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTopic({
    required String forumId,
    required String title,
    required String createdBy,
  }) async {
    await forumCollection.doc(forumId).collection('topics').add({
      'title': title,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addPost({
    required String forumId,
    required String topicId,
    required String content,
    required String createdBy,
  }) async {
    await forumCollection
        .doc(forumId)
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .add({
      'content': content,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getForums() {
    return forumCollection.snapshots();
  }

  Stream<QuerySnapshot> getTopics(String forumId) {
    return forumCollection.doc(forumId).collection('topics').snapshots();
  }

  Stream<QuerySnapshot> getPosts(String forumId, String topicId) {
    return forumCollection
        .doc(forumId)
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .snapshots();
  }
}
