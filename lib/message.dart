import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readswap/home_page.dart';
import 'package:readswap/CartPage.dart';
import 'package:readswap/sold_book_page.dart';
import 'package:readswap/profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainTabView(),
      routes: {
        '/home': (context) => HomePage(),
        '/mostLiked': (context) => MostLikedPostsPage(), // Route for most liked posts
      },
    );
  }
}

class MainTabView extends StatefulWidget {
  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SocialMedia(),
    CartPage(),
    SoldBooksPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Anasayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Sepet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: "Ara",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: "Profil",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF529471),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SocialMedia extends StatefulWidget {
  @override
  _SocialMediaState createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  Future<String?>? userNameFuture;
  Future<List<DocumentSnapshot>>? postsFuture;

  @override
  void initState() {
    super.initState();
    userNameFuture = _getUserName();
    postsFuture = _fetchPosts();
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

  Future<void> _updateLikes(String postId, int currentLikes, bool isLiked) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      if (isLiked) {
        await postRef.update({
          'likes': currentLikes - 1,
          'likedBy': FieldValue.arrayRemove([uid])
        });
      } else {
        await postRef.update({
          'likes': currentLikes + 1,
          'likedBy': FieldValue.arrayUnion([uid])
        });
      }
    }
  }

  Future<void> _addComment(String postId, String comment) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      String username = userDoc['username'] ?? 'Bilinmeyen Kullanıcı';

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([{
          'username': username,
          'comment': comment,
          'timestamp': Timestamp.now()
        }]),
      });
    }
  }

  bool _hasUserLikedPost(List<dynamic>? likedBy) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && likedBy != null) {
      return likedBy.contains(currentUser.uid);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Readswap"),
        backgroundColor: Color(0xFF529471),
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add notification functionality here
            },
          ),
        ],
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
                          'likedBy': [],
                          'createdAt': Timestamp.now(),
                        });
                        setState(() {
                          postsFuture = _fetchPosts();
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
        backgroundColor: Color(0xFF529471),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    List<dynamic> likedBy = post['likedBy'] ?? [];
    bool isLiked = _hasUserLikedPost(likedBy);

    return Card(
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Color(0xFF529471)),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF529471),
                  child: Text(
                    post['username'] != null
                        ? post['username'][0].toUpperCase()
                        : '?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  post['username'] ?? 'Kullanıcı Adı Yok',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF529471)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              post['title'] ?? '',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF529471),
                  fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(post['quote'] ?? ''),
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    _updateLikes(postId, post['likes'] ?? 0, isLiked);
                    setState(() {
                      postsFuture = _fetchPosts();
                    });
                  },
                ),
                Text('${post['likes'] ?? 0}'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Yorum ekle...',
                    ),
                    onSubmitted: (comment) {
                      _addComment(postId, comment);
                      setState(() {
                        postsFuture = _fetchPosts();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {}, // Optional: you can add functionality if needed
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class MostLikedPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("En Çok Beğenilenler"),
        backgroundColor: Color(0xFF529471),
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to HomePage
          },
        ),
      ),
      body: Center(child: Text('Most Liked Posts Page')), // Placeholder for the actual implementation
    );
  }
}
