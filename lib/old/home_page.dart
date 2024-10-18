import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readswap/old/categorybookscreen.dart';
import 'package:readswap/old/controller/HomeController.dart';


class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            _buildSearchBar(),
            _buildCategoriesSection(),
            _buildBestBooksSection(),
            _buildRecommendedBooksSection(),
            _buildBooksWithUserCoinsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, right: 20, bottom: 20, left: 20),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Merhaba, ${controller.userName.value}!",
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
      }),
    );
  }

  Widget _buildBestBooksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Son Eklenenler"),
          SizedBox(
            height: 400,
            child: Obx(() {
              if (controller.bestBooks.isEmpty) {
                return const Center(child: Text('No Data'));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.bestBooks.length,
                itemBuilder: (context, index) {
                  var book = controller.bestBooks[index].data() as Map<String, dynamic>;
                  return _buildBookCard(book, controller.bestBooks[index].id);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedBooksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Sizin İçin Önerilenler"),
          Obx(() {
            if (controller.recommendedBooks.isEmpty) {
              return const Center(child: Text('No recommended books found.'));
            }
            return SizedBox(
              height: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.recommendedBooks.length,
                itemBuilder: (context, index) {
                  var book = controller.recommendedBooks[index].data() as Map<String, dynamic>;
                  return _buildBookCard(book, controller.recommendedBooks[index].id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBooksWithUserCoinsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Coinin İle Alabileceklerin"),
          Obx(() {
            if (controller.booksByCoins.isEmpty) {
              return const Center(child: Text('No books available for your coins.'));
            }
            return SizedBox(
              height: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.booksByCoins.length,
                itemBuilder: (context, index) {
                  var book = controller.booksByCoins[index].data() as Map<String, dynamic>;
                  return _buildBookCard(book, controller.booksByCoins[index].id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, String bookId) {
    return GestureDetector(
      onTap: () {
        // BookDetails sayfasına git
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book['BookImage'] ?? '',
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
              book['UserName'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowText(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        GestureDetector(
          onTap: () {
            // Daha fazla kitap görüntüle (bu alan geliştirilebilir)
          },
          child: const Text(
            "Tümünü Gör",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF86BC96),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            hintText: "Kitap ara",
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          onChanged: (query) {
            // Arama işlemi için yazılan kelimeyi dinleyebilir
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowText("Kategoriler"),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                // You can use a better way to handle categories and their images
                String categoryName =
                    '$index'; // Replace with actual category names
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryBooksScreen(category: categoryName),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/Category$index.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.none,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(category),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
