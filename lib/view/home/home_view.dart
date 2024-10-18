import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readswap/common-widget/top_picks_cell.dart';
import 'package:readswap/contollers/HomeController.dart';
import 'package:readswap/view/main_tab_view.dart/main_tab_view.dart';
import '../../common-widget/best_seller_cell.dart';
import '../../common-widget/genres_cell.dart';
import '../../common-widget/recently_cell.dart';
import '../../common-widget/round_button.dart';
import '../../common-widget/round_textfield.dart';
import '../../common/color_extenstion.dart';
import '../../common/constants/genres_contansts.dart';
import '../book_reading/book_reading_view.dart';
import '../login/sign_up_view.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Instantiate the HomeController
  // final HomeController homeController = Get.put(HomeController());
  final HomeController homeController = Get.find<HomeController>();


  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  child: Transform.scale(
                    scale: 1.5,
                    origin: Offset(0, media.width * 0.8),
                    child: Container(
                      width: media.width,
                      height: media.width,
                      decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius:
                              BorderRadius.circular(media.width * 0.5)),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Row(children: const [
                        Text(
                          "Our Top Picks",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                      leading: Container(),
                      leadingWidth: 1,
                      actions: [
                        IconButton(
                            onPressed: () {
                              sideMenuScaffoldKey.currentState?.openEndDrawer();
                            },
                            icon: const Icon(Icons.menu))
                      ],
                    ),
//                     SizedBox(
//       width: media.width,
//       height: media.width * 0.8, // Adjust height to suit the carousel items
//       child: Obx(() {
//         if (homeController.bestBooks.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return CarouselSlider.builder(
//           itemCount: homeController.bestBooks.length,
//           itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
//             var iObj = homeController.bestBooks[itemIndex].data() as Map<String, dynamic>;
//             return TopPicksCell(
//               book: iObj, // Pass the book data into TopPicksCell
//             );
//       },
//       options: CarouselOptions(
//         autoPlay: false,
//         aspectRatio: 1,
//         enlargeCenterPage: true,
//         viewportFraction: 0.45,
//         enlargeFactor: 0.4,
//         enlargeStrategy: CenterPageEnlargeStrategy.zoom,
//       ),
//     );
//   }),
// ),


//---------------------------------------
//aşağıda stream builder ile yapılmış versiyonu bulunmakta eğer kitap eklendiğinde anasayfaya hemen düşmez ise bu yöntem kullanılacaktır 
//----------------------------------------
SizedBox(
  width: media.width,
  height: media.width * 0.8, // Carousel item yüksekliği
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('Books')
        .orderBy('CreatedAt', descending: true)
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots(), // Firestore'dan gelen canlı güncellemeleri dinler
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('Kitap bulunamadı'));
      }
      
      var books = snapshot.data!.docs;
      
      return CarouselSlider.builder(
        itemCount: books.length,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          var iObj = books[itemIndex].data() as Map<String, dynamic>;
          return TopPicksCell(
            book: iObj, // Kitap verisini gönder
          );
        },
        options: CarouselOptions(
          autoPlay: false,
          aspectRatio: 1,
          enlargeCenterPage: true,
          viewportFraction: 0.45,
          enlargeFactor: 0.4,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
        ),
      );
    },
  ),
),


                    // Rest of the UI remains unchanged
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Text(
                          "Bestsellers",
                          style: TextStyle(
                              color: TColor.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                    ),
SizedBox(
  height: media.width * 0.9,
  child: Obx(() {
    if (homeController.bestBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      scrollDirection: Axis.horizontal,
      itemCount: homeController.bestBooks.length,
      itemBuilder: (context, index) {
        var bObj = homeController.bestBooks[index].data() as Map<String, dynamic>;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookReadingView(bObj: bObj),
              ),
            );
          },
          child: BestSellerCell(
            book: bObj,
          ),
        );
      },
    );
  }),
),  
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Text(
                          "Genres",
                          style: TextStyle(
                              color: TColor.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                    ),
                    SizedBox(
                      height: media.width * 0.6,
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 8),
                          scrollDirection: Axis.horizontal,
                          itemCount: genresArr.length,
                          itemBuilder: ((context, index) {
                            var bObj = genresArr[index] as Map? ?? {};

                            return GenresCell(
                              bObj: bObj,
                              bgcolor: index % 2 == 0
                                  ? TColor.color1
                                  : TColor.color2,
                            );
                          })),
                    ),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Text(
                          "Recently Viewed",
                          style: TextStyle(
                              color: TColor.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                    ),
                    // SizedBox(
                    //   height: media.width * 0.7,
                    //   child: ListView.builder(
                    //       padding: const EdgeInsets.symmetric(
                    //           vertical: 15, horizontal: 8),
                    //       scrollDirection: Axis.horizontal,
                    //       itemCount: recentArr.length,
                    //       itemBuilder: ((context, index) {
                    //         var bObj = recentArr[index] as Map? ?? {};

                    //         return RecentlyCell(
                    //           iObj: bObj,
                    //         );
                    //       })),
                    // ),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Text(
                          "Monthly Newsletter",
                          style: TextStyle(
                              color: TColor.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                    ),
                    
                    Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                          color: TColor.textbox.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Receive our monthly newsletter and receive updates on new stock, books and the occasional promotion.",
                              style: TextStyle(
                                color: TColor.subTitle,
                                fontSize: 12,
                              ),
                            ),

                             const SizedBox(
                              height: 15,
                            ),

                             RoundTextField(
                              controller: txtName,
                              hintText: "Name",
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            RoundTextField(
                              controller: txtEmail,
                              hintText: "Email Address",
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                              MiniRoundButton(title: "Sign Up", onPressed: 
                              (){
                                 Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpView()));
                              }, )
                            ],)


                          ]),
                    ),
                  


                     SizedBox(
                      height: media.width * 0.1,
                    ),

                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
