import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readswap/book_details.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:readswap/category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readswap/firebase/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DocumentSnapshot>> bestBooksFuture;
  late Future<String?> userNameFuture;

  @override
  void initState() {
    super.initState();
    bestBooksFuture = _fetchBestBooks();
    userNameFuture =
        Auth().getUsername(); // Giriş yapan kullanıcının ismini alıyoruz.
  }

  Future<List<DocumentSnapshot>> _fetchBestBooks() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching best books: $e');
      }
      return [];
    }
  }

  Future<String> _getDownloadUrl(String gsUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching download URL: $e');
      return '';
    }
  }

  Future<String> _getUserName(DocumentReference userRef) async {
    try {
      var snapshot = await userRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot['username'] ?? '';
      } else {
        return 'No UserName';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 50, right: 20, bottom: 20, left: 20),
              child: FutureBuilder<String?>(
                future: userNameFuture,
                builder: (context, snapshot) {
                  String userName = snapshot.data ??
                      'Kullanıcı'; // Kullanıcı adı yoksa "Kullanıcı" yazsın.
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Merhaba, $userName!",
                        style: const TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF86BC96),
                        ),
                      ),
                      const Text(
                        "Her yerde aradığın kitap burada!",
                        style: TextStyle(
                          color: Color(0xFF6C6C6C),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Kitap veya kategori ara...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                ),
                cursorColor: const Color(0xFF787878),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildRowText("Kategoriler"),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14, // Example number of categories
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/Category$index.png', // Example image path
                    width: 70,
                    height: 70,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildRowText("Son Eklenenler"),
            ),
            SizedBox(
                height: 400,
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: bestBooksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Data'));
                    }

                    List<DocumentSnapshot> bestBooks = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: bestBooks.length,
                      itemBuilder: (context, index) {
                        var book =
                            bestBooks[index].data() as Map<String, dynamic>;

                        // Check if BookImage exists and is not null
                        if (book['BookImage'] == null) {
                          return _buildErrorWidget('No Image Available');
                        }

                        return FutureBuilder<String>(
                          future: _getDownloadUrl(book['BookImage']),
                          builder: (context, urlSnapshot) {
                            if (urlSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingWidget();
                            }
                            if (urlSnapshot.hasError) {
                              return _buildErrorWidget(
                                  'Error: ${urlSnapshot.error}');
                            }
                            if (!urlSnapshot.hasData ||
                                urlSnapshot.data!.isEmpty) {
                              return _buildErrorWidget('No Image URL');
                            }

                            String imageUrl = urlSnapshot.data!;

                            return FutureBuilder<String>(
                              future: _getUserName(book['UserId']),
                              builder: (context, userNameSnapshot) {
                                if (userNameSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildLoadingWidget();
                                }
                                if (userNameSnapshot.hasError) {
                                  return _buildErrorWidget(
                                      'Error: ${userNameSnapshot.error}');
                                }
                                if (!userNameSnapshot.hasData ||
                                    userNameSnapshot.data!.isEmpty) {
                                  return _buildErrorWidget('No User Data');
                                }

                                String userName = userNameSnapshot.data!;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetails(
                                          bookId: bestBooks[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 250,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 300,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                height: 300,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            book['BookTitle'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            userName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildRowText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ListTileLearn()),
              );
            },
            child: const Text(
              "Hepsini Gör",
              style: TextStyle(color: Colors.green, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String message) {
    return Center(child: Text(message));
  }
}
