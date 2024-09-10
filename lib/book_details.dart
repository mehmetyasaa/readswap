import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readswap/firebase/auth.dart';
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

  @override
  void initState() {
    super.initState();
    bookFuture = _fetchBookDetails();
  }

  Future<DocumentSnapshot> _fetchBookDetails() async {
    return await FirebaseFirestore.instance
        .collection('Books')
        .doc(widget.bookId)
        .get();
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    final ref = FirebaseStorage.instance.refFromURL(gsUrl);
    return await ref.getDownloadURL();
  }

  Future<void> _addComment(String commentText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen yorum yapmak için giriş yapınız.')),
      );
      return;
    }

    // Kullanıcı verilerini al
    final userData = await Auth().getUserData();

    final commentData = {
      'username': userData?['username'] ?? 'Anonim', // Kullanıcı adı
      'commentText': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('Books')
        .doc(widget.bookId)
        .collection('Comments')
        .add(commentData);

    _commentController.clear();
    setState(() {}); // Refresh to show the new comment
  }

  Widget _buildCommentsSection() {
    return ExpansionTile(
      title: const Text('Yorumlar'),
      children: [
        // Display existing comments
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
                            .substring(0, 16) // Display up to minutes
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const Divider(),
        // Form to add a new comment
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back Button and Title
                  // Row(
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(Icons.arrow_back),
                  //       onPressed: () => Navigator.pop(context),
                  //     ),
                  //     Expanded(
                  //       child: Text(
                  //         book['BookTitle'] ?? '',
                  //         style: const TextStyle(
                  //             fontSize: 18, fontWeight: FontWeight.bold),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 10),

                  // Book Image
                  FutureBuilder<String>(
                    future: _getDownloadUrl(book['BookImage']),
                    builder: (context, urlSnapshot) {
                      if (urlSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (urlSnapshot.hasError) {
                        return Center(
                            child: Text('Hata: ${urlSnapshot.error}'));
                      }

                      if (!urlSnapshot.hasData || urlSnapshot.data!.isEmpty) {
                        return Center(child: Text('Resim Bulunamadı'));
                      }

                      String imageUrl = urlSnapshot.data!;
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.blueAccent, width: 2.0),
                          ),
                          child: Image.network(imageUrl, height: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Author Name
                  Text(
                    book['BookWriter'] ?? 'Bilinmeyen',
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Rating and Reviews
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.black, size: 20),
                      Icon(Icons.star, color: Colors.black, size: 20),
                      Icon(Icons.star, color: Colors.black, size: 20),
                      Icon(Icons.star, color: Colors.black, size: 20),
                      Icon(Icons.star_half, color: Colors.black, size: 20),
                      SizedBox(width: 5),
                      Text(
                        '4.5',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ReadSwap Marketing Label
                  const Text(
                    'ReadSwap Pazarlama',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),

                  // Expansion Tiles for Description, Questions, Return Policies, and Comments
                  ExpansionTile(
                    title: const Text('Ürün Açıklaması'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(book['BookDescription'] ?? ''),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('Soru&Cevap'),
                    children: [
                      // Add relevant question and answer widgets
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('İptal ve İade koşulları'),
                    children: [
                      // Add return policy content
                    ],
                  ),
                  // Comments Section
                  _buildCommentsSection(),
                  const SizedBox(height: 20),

                  // Price and Buttons
                  Text(
                    book['BookPrice'] + " RS Coin" ?? 'Bulunamadı',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Action for Teklif Ver
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Teklif Ver'),
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
                                      sellerId: (book['UserId']
                                              as DocumentReference)
                                          .id, // Satıcı ID'sini doğru şekilde al
                                      price:
                                          bookPrice, // Fiyatı double olarak geçir
                                      shippingCost: 100,
                                    )),
                          );
                          // Convert the book price to double before passing it
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('Satın Al'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
