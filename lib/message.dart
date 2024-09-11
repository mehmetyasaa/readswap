import 'package:flutter/material.dart';
import 'package:readswap/TabView.dart';

void main() => runApp(SocialMedia());

class SocialMedia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [
    Post(
      username: 'sametsargin',
      bookTitle: 'Sait Faik Abasıyanık - Lüzumsuz Adam',
      quote: 'Bu koca şehir, ne kadar birbirine yabancı insanlarla dolu.',
    ),
    Post(
      username: 'mehmetyasa',
      bookTitle: 'Oğuz Atay - Tutunamayanlar',
      quote:
          'Başkalarının yaptıklarını silmeye çalıştım. Mürekkeple yazmışlar. Oysa ben kurşun kalem silgisiydim, azaldığımla kaldım.',
    ),
    Post(
      username: 'umutemel',
      bookTitle: 'Franz Kafka - Dönüşüm',
      quote: 'Herkes beraberinde taşıdığı bir parmaklığın ardında yaşıyor.',
    ),
  ];

  List<Post> mostLikedPosts() {
    List<Post> sortedPosts = List.from(posts);
    sortedPosts.sort((a, b) => b.likes.compareTo(a.likes));
    return sortedPosts;
  }

  bool showMostLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TabView()), // TabView sayfasına yönlendirme
            );
          },
        ),
        title: Text('ReadSwap'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showMostLiked = false;
                    });
                  },
                  child: Text('Öne Çıkanlar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showMostLiked = true;
                    });
                  },
                  child: Text('En Beğenilen'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: showMostLiked
                  ? mostLikedPosts()
                      .map((post) => PostWidget(post: post))
                      .toList()
                  : posts.map((post) => PostWidget(post: post)).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sepet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class Post {
  final String username;
  final String bookTitle;
  final String quote;
  int likes;
  int comments;
  int shares;

  Post({
    required this.username,
    required this.bookTitle,
    required this.quote,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  });
}

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;

  void toggleLike() {
    setState(() {
      if (isLiked) {
        widget.post.likes--;
      } else {
        widget.post.likes++;
      }
      isLiked = !isLiked;
    });
  }

  void addComment() async {
    TextEditingController commentController = TextEditingController();
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yorum Yap'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Yorumunuzu yazın'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Gönder'),
              onPressed: () {
                Navigator.of(context).pop(commentController.text);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        widget.post.comments++;
      });
      // Burada yorumunuzu kaydedebilirsiniz veya başka bir işlem yapabilirsiniz.
      print('Yapılan Yorum: $result');
    }
  }

  void sharePost() {
    setState(() {
      widget.post.shares++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(Icons.person),
                ),
                SizedBox(width: 8.0),
                Text(widget.post.username),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              widget.post.bookTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(widget.post.quote),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: toggleLike,
                ),
                Text(widget.post.likes.toString()),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: addComment,
                ),
                Text(widget.post.comments.toString()),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: sharePost,
                ),
                Text(widget.post.shares.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
