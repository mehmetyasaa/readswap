import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readswap/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SocialMedia(),
      routes: {
        '/home': (context) => HomePage(), // Yeni rota tanımlaması
      },
    );
  }
}

class SocialMedia extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<SocialMedia> {
  Future<String?>? userNameFuture;
  Future<List<DocumentSnapshot>>? postsFuture;

  @override
  void initState() {
    super.initState();
    userNameFuture = _getUserName();
    postsFuture = _fetchPosts(); // Initialize postsFuture
  }

  Future<String?> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      return userDoc['username'] as String?;
    }
    return null;
  }

  Future<List<DocumentSnapshot>> _fetchPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<void> _updateLikes(String postId, int currentLikes) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': currentLikes + 1,
    });
  }

  Future<void> _addComment(String postId, String comment) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([
          {
            'username': currentUser.displayName ?? 'Unknown',
            'comment': comment,
            'timestamp': Timestamp.now()
          }
        ]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home'); // Yönlendirme
          },
        ),
        title: Text("Post Sayfası"),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          List<DocumentSnapshot> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index].data() as Map<String, dynamic>;
              return _buildPostCard(post, posts[index].id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String title = '';
              String quote = '';
              return AlertDialog(
                title: Text('Yeni Alıntı Ekle'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Alıntı Başlığı'),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Alıntı'),
                      onChanged: (value) {
                        quote = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('İptal'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Kaydet'),
                    onPressed: () async {
                      String? username = await userNameFuture;
                      if (username != null) {
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .add({
                          'username': username,
                          'quote': quote,
                          'title': title,
                          'likes': 0,
                          'comments': [],
                          'createdAt': Timestamp.now(), // Eklenen zaman damgası
                        });
                        setState(() {
                          postsFuture = _fetchPosts(); // Listeyi yeniden yükle
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'] ?? 'Başlık Yok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(post['quote'] ?? 'Alıntı Yok'),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () async {
                    int currentLikes = post['likes'] ?? 0;
                    await _updateLikes(postId, currentLikes);
                    setState(() {
                      postsFuture = _fetchPosts(); // Listeyi güncelle
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String comment = '';
                        return AlertDialog(
                          title: Text('Yorum Ekle'),
                          content: TextField(
                            decoration:
                                InputDecoration(labelText: 'Yorumunuzu yazın'),
                            onChanged: (value) {
                              comment = value;
                            },
                          ),
                          actions: [
                            TextButton(
                              child: Text('İptal'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Kaydet'),
                              onPressed: () async {
                                await _addComment(postId, comment);
                                setState(() {
                                  postsFuture =
                                      _fetchPosts(); // Listeyi güncelle
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Text('Beğeni: ${post['likes'] ?? 0}'),
            SizedBox(height: 8),
            _buildCommentsSection(post['comments']),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(List<dynamic>? comments) {
    if (comments == null || comments.isEmpty) {
      return Text('Yorum Yok');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comments.map<Widget>((comment) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '${comment['username']}: ${comment['comment']}',
            style: TextStyle(color: Colors.grey[700]),
          ),
        );
      }).toList(),
    );
  }
}
