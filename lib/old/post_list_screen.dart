import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readswap/old/controller/form_controller.dart';

class PostListScreen extends StatelessWidget {
  final String forumId;
  final String topicId;
  final ForumController forumController = ForumController();

  PostListScreen({required this.forumId, required this.topicId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: forumController.getPosts(forumId, topicId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post['content']),
                subtitle: Text(post['createdBy']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddPostDialog(context);
        },
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Post'),
          content: TextField(
            controller: contentController,
            decoration: InputDecoration(labelText: 'Content'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                forumController.addPost(
                  forumId: forumId,
                  topicId: topicId,
                  content: contentController.text,
                  createdBy: 'user', // replace with actual user ID
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
