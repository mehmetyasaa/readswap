import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readswap/TabView.dart';

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  List<String> categories = [
    'Bilim',
    'Edebiyat',
    'Çocuk',
    'Eğitim',
    'Biyografi',
    'Tarih',
    'Roman',
    'Polisiye',
    'Otobiyografi',
    'Savaş',
    'Ev Yaşam',
    'Makale',
    'Aşk',
    'Araştırma',
    'Tiyatro'
  ];

  List<String> selectedCategories = []; // Seçilen kategoriler

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorileri Seçin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 3 / 2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategories.contains(category);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedCategories.remove(category);
                  } else {
                    selectedCategories.add(category);
                  }
                });
              },
              child: CategoryTile(
                title: category,
                imagePath: 'assets/Category$index.png',
                isSelected: isSelected,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Kullanıcı kimliği al
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Firestore'daki kullanıcı verisini güncelle
            final userDoc =
                FirebaseFirestore.instance.collection('Users').doc(user.uid);

            // Seçilen kategorileri kullanıcının dökümanına ekle
            await userDoc.update({
              'selectedCategories': selectedCategories,
            });

            // TabView sayfasına yönlendir
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TabView()),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;

  const CategoryTile({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (isSelected)
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
