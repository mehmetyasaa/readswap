import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:readswap/service/purchase_controller.dart';

class BookDetails extends StatefulWidget {
  final String bookId;

  const BookDetails({Key? key, required this.bookId}) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late Future<DocumentSnapshot> bookFuture;
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _averageRating = 0.0;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    bookFuture = _fetchBookDetails();
    _checkIfFavorited();
  }

  Future<DocumentSnapshot> _fetchBookDetails() async {
    final bookDoc = await FirebaseFirestore.instance
        .collection('Books')
        .doc(widget.bookId)
        .get();

    setState(() {
      _averageRating = bookDoc.data()?['averageRating']?.toDouble() ?? 0.0;
    });

    return bookDoc;
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    final ref = FirebaseStorage.instance.refFromURL(gsUrl);
    return await ref.getDownloadURL();
  }

  Future<void> _addComment(String commentText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen yorum yapmak için giriş yapınız.')),
      );
      return;
    }

    final userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    final commentData = {
      'username': userData['username'] ?? 'Anonim',
      'commentText': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('Books')
        .doc(widget.bookId)
        .collection('Comments')
        .add(commentData);

    _commentController.clear();
    setState(() {});
  }

  Future<void> _saveReview(double rating, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapınız.')),
      );
      return;
    }

    final reviewData = {
      'UserId': user.uid,
      'Rating': rating,
      'Comment': comment,
      'BookId': widget.bookId,
      'ReviewDate': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('Review').add(reviewData);

    await _updateAverageRating();
  }

  Future<void> _updateAverageRating() async {
    final reviewSnapshot = await FirebaseFirestore.instance
        .collection('Review')
        .where('BookId', isEqualTo: widget.bookId)
        .get();

    double totalRating = 0;
    for (var doc in reviewSnapshot.docs) {
      totalRating += doc.data()['Rating'];
    }

    double averageRating =
        reviewSnapshot.size > 0 ? totalRating / reviewSnapshot.size : 0.0;

    await FirebaseFirestore.instance
        .collection('Books')
        .doc(widget.bookId)
        .update({'averageRating': averageRating});

    setState(() {
      _averageRating = averageRating;
    });
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double rating = 0;
        TextEditingController commentController = TextEditingController();

        return AlertDialog(
          title: const Text('Değerlendirme Yapın'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Yorumunuzu yazın',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveReview(rating, commentController.text);
              },
              child: const Text('Değerlendir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoriteDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Favorites')
        .doc(widget.bookId)
        .get();

    setState(() {
      _isFavorited = favoriteDoc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoriteRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Favorites')
        .doc(widget.bookId);

    if (_isFavorited) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({'bookId': widget.bookId});
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  Widget _buildCommentsSection() {
    return ExpansionTile(
      title: const Text('Yorumlar'),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Books')
              .doc(widget.bookId)
              .collection('Comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Henüz yorum yapılmamış. İlk yorumu siz yapın!'),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['username'] ?? 'Anonim'),
                  subtitle: Text(data['commentText'] ?? ''),
                  trailing: Text(
                    data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                            .substring(0, 16)
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Yorumunuzu yazın',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Yorum boş olamaz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addComment(_commentController.text.trim());
                    }
                  },
                  child: const Text('Yorumu Gönder'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitap Detayları"),
        actions: [
          IconButton(
            icon: Icon(
                           _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.star_rate),
            onPressed: _showRatingDialog,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Veri Bulunamadı'));
          }

          var book = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Book Image
                  FutureBuilder<String>(
                    future: _getDownloadUrl(book['BookImage']),
                    builder: (context, urlSnapshot) {
                      if (urlSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (urlSnapshot.hasError) {
                        return Center(child: Text('Hata: ${urlSnapshot.error}'));
                      }

                      if (!urlSnapshot.hasData || urlSnapshot.data!.isEmpty) {
                        return Center(child: Text('Resim Bulunamadı'));
                      }

                      String imageUrl = urlSnapshot.data!;
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8.0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(imageUrl, height: 300, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Author Name
                  Text(
                    book['BookWriter'] ?? 'Bilinmeyen',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Rating and Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: _averageRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          // Optional: handle rating update here
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ReadSwap Marketing Label
                  const Text(
                    'ReadSwap Pazarlama',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Expansion Tiles for Description, Questions, Return Policies, and Comments
                  ExpansionTile(
                    title: const Text('Ürün Açıklaması'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          book['BookDescription'] ?? 'Açıklama bulunamadı.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('Soru & Cevap'),
                    children: [
                      // Add relevant question and answer widgets
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Henüz soru yok. Sorunuzu yazın!'),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('İptal ve İade Koşulları'),
                    children: [
                      // Add return policy content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('İptal ve iade koşulları hakkında bilgi bulunamadı.'),
                      ),
                    ],
                  ),
                  _buildCommentsSection(),
                  const SizedBox(height: 20),

                  // Price and Buttons
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${book['BookPrice']} RS Coin',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lütfen giriş yapınız.')),
                                  );
                                  return;
                                }

                                // Reference to the user's cart in Firestore
                                final cartRef = FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(user.uid)
                                    .collection('Cart')
                                    .doc(widget.bookId);

                                // Adding the book to the cart
                                await cartRef.set({
                                  'bookId': widget.bookId,
                                  'quantity': 1, // You can add quantity if needed
                                  'addedAt': FieldValue.serverTimestamp(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sepete eklendi!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text(
                                'Sepete Ekle',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                double bookPrice =
                                    double.tryParse(book['BookPrice']) ?? 0.0;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CheckoutPage(
                                            bookId: widget.bookId,
                                            sellerId:
                                                (book['UserId'] as DocumentReference)
                                                    .id,
                                            price: bookPrice,
                                            shippingCost: 100,
                                          )),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text(
                                'Satın Al',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

