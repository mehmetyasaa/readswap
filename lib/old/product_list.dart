import 'package:flutter/material.dart';
import 'package:readswap/old/category.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final int starCount;
  final String imageURL;

  ProductCard({
    required this.productName,
    required this.price,
    required this.starCount,
    required this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            imageURL,
            height: 200,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      starCount.toString(),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$$price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String _selectedFilter = 'Filtrele';
  String _selectedSort = 'Sırala';
  List<ProductCard> products = [
    ProductCard(
      productName: 'B',
      price: 99.99,
      starCount: 4,
      imageURL: 'assets/atam.jpeg',
    ),
    ProductCard(
      productName: 'A',
      price: 149.99,
      starCount: 3,
      imageURL: 'assets/witcher.png',
    ),
    ProductCard(
      productName: 'D',
      price: 99.99,
      starCount: 4,
      imageURL: 'https://via.placeholder.com/300',
    ),
    ProductCard(
      productName: 'C',
      price: 99.99,
      starCount: 2,
      imageURL: 'https://via.placeholder.com/300',
    ),
    ProductCard(
      productName: 'G',
      price: 99.99,
      starCount: 2,
      imageURL: 'https://via.placeholder.com/300',
    ),
    ProductCard(
      productName: 'U',
      price: 99.99,
      starCount: 2,
      imageURL: 'https://via.placeholder.com/300',
    ),
    ProductCard(
      productName: 'Z',
      price: 99.99,
      starCount: 2,
      imageURL: 'https://via.placeholder.com/300',
    ),
    ProductCard(
      productName: 'X',
      price: 99.99,
      starCount: 2,
      imageURL: 'https://via.placeholder.com/300',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("İlanlar"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: _selectedFilter,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                    if (_selectedFilter == 'Kategoriye Göre') {
                      // Kategoriye göre filtreleme seçildiğinde ListTileLearn sınıfını getir
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListTileLearn()),
                      );
                    }
                  });
                },
                items: <String>[
                  'Filtrele',
                  'Kategoriye Göre',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt_rounded), // İstediğiniz simge
                        SizedBox(
                            width:
                                5), // İkon ile metin arasında bir boşluk ekledik
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: _selectedSort,
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == 'Sırala') {
                      // 'Sırala' seçeneğine basıldığında sıralamanın geri dönmesi sağlanıyor
                      products.sort(
                        (a, b) =>
                            products.indexOf(a).compareTo(products.indexOf(b)),
                      );
                    } else if (newValue == 'Alfabetik') {
                      // 'Alfabetik' seçeneğine basıldığında ürünleri alfabetik olarak sırala
                      products.sort(
                        (a, b) => a.productName.compareTo(b.productName),
                      );
                    }
                    _selectedSort = newValue!;
                  });
                },
                items: <String>[
                  'Sırala',
                  'Alfabetik',
                  'Kategoriye Göre',
                  'Satışa Göre'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.sort), // İstediğiniz simge
                        SizedBox(width: 5),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return products[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductList(),
  ));
}
