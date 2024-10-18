import 'package:flutter/material.dart';
import '../common/color_extenstion.dart';

class TopPicksCell extends StatelessWidget {
  final Map<String, dynamic> book;
  // final String bookId;
  const TopPicksCell({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        // Navigate to the book details page when tapped
        // Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsView(bookId: bookId)));
      },
      child: SizedBox(
        width: media.width * 0.32, // Adjust the width of the book card
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Book Image Section
            Container(
               // Adjust the height of the book image
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
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
                  book['BookImage'] ?? '', // Book image URL from the book map
                   width: media.width * 0.32,
                  height: media.width * 0.50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 15), // Spacing between the image and title

            // Book Title Section
            Text(
              book['BookTitle'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Book Author Section
            Text(
              book['UserName'] ?? 'deneme',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.subTitle,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
