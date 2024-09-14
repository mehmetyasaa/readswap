import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readswap/TabView.dart';

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
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
            crossAxisCount: 3, // Daha fazla sütun
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0, // Çocukların en-boy oranı
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
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final userDoc =
                FirebaseFirestore.instance.collection('Users').doc(user.uid);

            await userDoc.update({
              'selectedCategories': selectedCategories,
            });

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
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 50.0, // İkon genişliği
                height: 50.0, // İkon yüksekliği
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14, // Küçük font boyutu
                  color: Colors.black, // Siyah yazı rengi
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
