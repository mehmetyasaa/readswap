import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../common/color_extenstion.dart';

class BestSellerCell extends StatelessWidget {
  final Map<String, dynamic> book;
  
  const BestSellerCell({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: media.width * 0.32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                book['BookImage'] ?? '', // Firebase'den aldığınız resim URL'si
                width: media.width * 0.32,
                height: media.width * 0.50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error); // Hata olduğunda gösterilecek ikon
                },
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // Resim başarıyla yüklendiğinde gösterilecek widget
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            book['BookTitle'] ?? '', // Kitap başlığı
            maxLines: 3,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: TColor.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            book['UserName'] ?? 'deneme', // Kullanıcı adı
            maxLines: 1,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: TColor.subTitle,
              fontSize: 11,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          // IgnorePointer(
          //     ignoring: true,
          //     child: RatingBar.builder(
          //       initialRating: double.tryParse(bObj["rating"].toString()) ?? 1,
          //       minRating: 1,
          //       direction: Axis.horizontal,
          //       allowHalfRating: true,
          //       itemCount: 5,
          //       itemSize: 15,
          //       itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
          //       itemBuilder: (context, _) => Icon(
          //         Icons.star,
          //         color: TColor.primary,
          //       ),
          //       onRatingUpdate: (rating) {},
          //     ),
          //   )
        ],
      ),
    );
  }
}
