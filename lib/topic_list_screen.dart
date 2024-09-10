import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readswap/controller/form_controller.dart';
import 'package:readswap/post_list_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String forumId;
  final ForumController forumController = ForumController();

  TopicListScreen({required this.forumId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: forumController.getTopics(forumId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final topics = snapshot.data!.docs;
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Text(topic['title']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostListScreen(
                        forumId: forumId,
                        topicId: topic.id,
                      ),
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
          _showAddTopicDialog(context);
        },
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Topic'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
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
                forumController.addTopic(
                  forumId: forumId,
                  title: titleController.text,
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
