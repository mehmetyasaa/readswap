import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:readswap/old/service/book_service.dart';

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final TextEditingController kitapAdiController = TextEditingController();
  final TextEditingController urunAciklamasiController =
      TextEditingController();
  final TextEditingController fiyatController = TextEditingController();

  String selectedCategory = '';
  String selectedCondition = '';
  List<File> _images = [];

  List<String> kategoriler = [
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

  List<String> durumlar = ['Sıfır', 'İkinci El'];

  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        print('Resim seçilmedi');
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('book_images/$fileName.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void handleSubmit() async {
    if (_images.isNotEmpty) {
      List<String> uploadedImageUrls = [];
      for (var image in _images) {
        String imageUrl = await _uploadImage(image);
        uploadedImageUrls.add(imageUrl);
      }

      // Other fields to save to Firestore
      String BookDescription = urunAciklamasiController.text;
      String BookImage =
          uploadedImageUrls.isNotEmpty ? uploadedImageUrls[0] : '';
      String BookIsbn = "0000";
      String BookPrice = fiyatController.text;
      String BookStatus = selectedCondition;
      String BookTitle = kitapAdiController.text;
      String BookWriter = "Unknown";

      // Ensure the selected category is passed to the backend
      String CategoryId = selectedCategory; // Set selected category

      // Call the create method with the updated parameters
      BookService()
          .create(BookDescription, BookImage, BookIsbn, BookPrice, BookStatus,
              BookTitle, BookWriter, CategoryId)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kitap eklendi!"),
        ));
        Navigator.of(context).pop();
      });
    } else {
      print("Lütfen bir resim seçin.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitap Ekle"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text("Fotoğraflar")],
                ),
              ),
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  height: 200,
                  child: _images.isEmpty
                      ? const Center(child: Text('Resim Seç'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  width: 150,
                                  height: 200,
                                  child: Image.file(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0)
                                                .withOpacity(0.4),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Kitap Adı",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              TextField(
                controller: kitapAdiController,
                decoration: const InputDecoration(hintText: "Kitap Adı"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Ürün Açıklaması",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              TextField(
                controller: urunAciklamasiController,
                decoration: const InputDecoration(hintText: "Ürün Açıklaması"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Fiyatı",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              TextField(
                controller: fiyatController,
                decoration: const InputDecoration(hintText: "Fiyatı"),
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "Kategoriler",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
                children: [
                  Wrap(
                    children: kategoriler
                        .map((kategori) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = kategori;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedCategory == kategori
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(kategori),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "Durumu",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
                children: [
                  Wrap(
                    children: durumlar
                        .map((durum) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCondition = durum;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedCondition == durum
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(durum),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: handleSubmit, child: const Text("Ürünü Ekle")),
            ],
          ),
        ),
      ),
    );
  }
}