import 'package:flutter/material.dart';

//
//bu sayfadaki kategorilerdeki resimler ayarlanacak
//
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
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 20,
          ),
        ),
        onTap: () {},
        leading: Image.asset(
          imagePath,
          width: 70,
          height: 70,
        ),
        trailing: Image.asset('assets/ok.png'),
      ),
    );
  }
}

class ListTileLearn extends StatelessWidget {
  const ListTileLearn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(185, 2, 201, 108),
        title: Text('Kategoriler'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Buraya arama işlemleri ekleyebilirsiniz
            },
          ),
        ],
      ),
      body: ListView(
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
                prefixIcon: Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  // Bu, odaklandığında çerçeve rengi
                  borderSide: BorderSide(
                    color: Colors.grey[300]!, // Odaklandığında çerçeve rengi
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              cursorColor: const Color.fromARGB(255, 120, 120, 120),
            ),
          ),
          const CategoryTile(
            title: 'Bilim',
            imagePath: 'assets/Category12.png',
          ),
          CategoryTile(
            title: 'Edebiyat',
            imagePath: 'assets/Category0.png',
          ),
          CategoryTile(
            title: 'Çocuk',
            imagePath: 'assets/Category1.png',
          ),
          CategoryTile(
            title: 'Eğitim',
            imagePath: 'assets/Category2.png',
          ),
          CategoryTile(
            title: 'Biyografi',
            imagePath: 'assets/Category3.png',
          ),
          CategoryTile(
            title: 'Tarih',
            imagePath: 'assets/Category4.png',
          ),
          CategoryTile(
            title: 'Roman',
            imagePath: 'assets/Category5.png',
          ),
          CategoryTile(
            title: 'Polisiye',
            imagePath: 'assets/Category6.png',
          ),
          CategoryTile(
            title: 'Otobiyografi',
            imagePath: 'assets/Category7.png',
          ),
          CategoryTile(
            title: 'Savaş',
            imagePath: 'assets/Category8.png',
          ),
          CategoryTile(
            title: 'Ev Yaşam',
            imagePath: 'assets/Category9.png',
          ),
          CategoryTile(
            title: 'Makale',
            imagePath: 'assets/Category10.png',
          ),
          CategoryTile(
            title: 'Aşk',
            imagePath: 'assets/Category11.png',
          ),
          CategoryTile(
            title: 'Araştırma',
            imagePath: 'assets/Category12.png',
          ),
          CategoryTile(
            title: 'En Sevilenler',
            imagePath: 'assets/Category12.png',
          ),
          CategoryTile(
            title: 'Tiyatro',
            imagePath: 'assets/Category11.png',
          ),
        ],
      ),
    );
  }
}
