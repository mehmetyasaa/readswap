import 'package:flutter/material.dart';
import 'package:readswap/BookListScreen.dart';

class ListTileLearn extends StatefulWidget {
  const ListTileLearn({Key? key}) : super(key: key);

  @override
  _ListTileLearnState createState() => _ListTileLearnState();
}

class _ListTileLearnState extends State<ListTileLearn> {
  List<Map<String, String>> categories = [
    {'title': 'Bilim', 'imagePath': 'assets/Category12.png'},
    {'title': 'Edebiyat', 'imagePath': 'assets/Category0.png'},
    {'title': 'Çocuk', 'imagePath': 'assets/Category1.png'},
    {'title': 'Eğitim', 'imagePath': 'assets/Category2.png'},
    {'title': 'Biyografi', 'imagePath': 'assets/Category3.png'},
    {'title': 'Tarih', 'imagePath': 'assets/Category4.png'},
    {'title': 'Roman', 'imagePath': 'assets/Category5.png'},
    {'title': 'Polisiye', 'imagePath': 'assets/Category6.png'},
    {'title': 'Otobiyografi', 'imagePath': 'assets/Category7.png'},
    {'title': 'Savaş', 'imagePath': 'assets/Category8.png'},
    {'title': 'Ev Yaşam', 'imagePath': 'assets/Category9.png'},
    {'title': 'Makale', 'imagePath': 'assets/Category10.png'},
    {'title': 'Aşk', 'imagePath': 'assets/Category11.png'},
    {'title': 'Araştırma', 'imagePath': 'assets/Category12.png'},
    {'title': 'En Sevilenler', 'imagePath': 'assets/Category12.png'},
    {'title': 'Tiyatro', 'imagePath': 'assets/Category11.png'},
  ];

  List<Map<String, String>> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = categories; // Initially show all categories
  }

  void _filterCategories(String query) {
    final results = categories.where((category) {
      final titleLower = category['title']!.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.startsWith(searchLower);
    }).toList();

    setState(() {
      filteredCategories = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(185, 2, 201, 108),
        title: const Text('Kategoriler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality can be added here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Kategori ara...",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: const Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              cursorColor: const Color.fromARGB(255, 120, 120, 120),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return CategoryTile(
                  title: category['title']!,
                  imagePath: category['imagePath']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String imagePath;

  const CategoryTile({
    Key? key,
    required this.title,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // Navigate to BookListScreen and pass the selected category
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookListScreen(category: title),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
