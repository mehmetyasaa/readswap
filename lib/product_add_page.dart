import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final TextEditingController bookTitleController = TextEditingController();
  final TextEditingController bookDescriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String selectedCategory = '';
  String selectedCondition = '';
  List<File> _images = [];

  List<String> categories = ['Science', 'Literature', 'Children', 'Education', 'Biography', 'History'];
  List<String> conditions = ['New', 'Used'];

  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('book_images/$fileName.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  void handleSubmit() async {
    if (_images.isNotEmpty) {
      List<String> uploadedImageUrls = [];
      for (var image in _images) {
        String imageUrl = await _uploadImage(image);
        uploadedImageUrls.add(imageUrl);
      }

      // Prepare data to send to backend
      String bookDescription = bookDescriptionController.text;
      String bookImage = uploadedImageUrls.isNotEmpty ? uploadedImageUrls[0] : '';
      String bookPrice = priceController.text;
      String bookStatus = selectedCondition;
      String bookTitle = bookTitleController.text;
      String categoryId = selectedCategory;

      // Call the service to save the book data
      FirebaseFirestore.instance.collection('books').add({
        'title': bookTitle,
        'description': bookDescription,
        'price': bookPrice,
        'status': bookStatus,
        'imageUrl': bookImage,
        'category': categoryId,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Book added!"),
        ));
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to add book: $error"),
        ));
      });
    } else {
      print("Please select an image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Book"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: _images.isEmpty
                      ? const Center(child: Text('Select Image'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Image.file(
                                  _images[index],
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: const Icon(Icons.close, color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: bookTitleController,
                decoration: const InputDecoration(labelText: "Book Title"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: bookDescriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedCategory.isEmpty ? null : selectedCategory,
                hint: const Text("Select Category"),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedCondition.isEmpty ? null : selectedCondition,
                hint: const Text("Select Condition"),
                items: conditions.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCondition = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
