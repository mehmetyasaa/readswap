import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readswap/old/controller/form_controller.dart';
import 'package:readswap/old/topic_list_screen.dart';

class ForumListScreen extends StatelessWidget {
  final ForumController forumController = ForumController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Forums'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: forumController.getForums(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final forums = snapshot.data!.docs;
          return ListView.builder(
            itemCount: forums.length,
            itemBuilder: (context, index) {
              final forum = forums[index];
              return ListTile(
                title: Text(forum['title']),
                subtitle: Text(forum['description']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicListScreen(forumId: forum.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddForumDialog(context);
        },
      ),
    );
  }

  void _showAddForumDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Forum'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
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
                forumController.createForum(
                  title: titleController.text,
                  description: descriptionController.text,
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
