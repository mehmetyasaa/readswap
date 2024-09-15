import 'package:flutter/material.dart';
import 'package:readswap/LikedItemsPage.dart';
import 'package:readswap/address_page.dart';
import 'package:readswap/coin.dart';
import 'package:readswap/orderpage.dart';
import 'package:readswap/ProfileUpdate.dart';
import 'package:readswap/sold_book_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Sayfası',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<String?> userNameFuture;

  @override
  void initState() {
    super.initState();
    userNameFuture = getUsername();
  }

  Future<String?> getUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        return userSnapshot['username'];
      }
      return null;
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: Color(0xFF7FA99B),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 85,
                    backgroundImage: AssetImage(
                        'assets/atam.jpeg'), // Profil resmi buraya eklenebilir
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FutureBuilder<String?>( 
                      future: userNameFuture,
                      builder: (context, snapshot) {
                        String userName = snapshot.data ?? 'Kullanıcı'; // Kullanıcı adı yoksa "Kullanıcı" yazsın.
                        return Text(
                          userName,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 10),
                _buildListItem(
                    context, OrderPage(), 'Siparişlerim', Icons.shopping_cart),
                SizedBox(height: 10),
                _buildListItem(
                    context, SoldBooksPage(), 'Satığım Kitaplar', Icons.sell),
                SizedBox(height: 10),
                _buildListItem(
                    context, CoinBalancePage(), 'Coinlerim', Icons.star),
                SizedBox(height: 10),
                _buildListItem(
                    context, null, 'Kuponlarım', Icons.card_giftcard),
                SizedBox(height: 10),
                _buildListItem(
                    context, LikedItemsPage(), 'Beğendiklerim', Icons.favorite), // Updated here
                SizedBox(height: 10),
                _buildListItem(
                    context, AddressPage(), 'Adreslerim', Icons.location_on),
                SizedBox(height: 10),
                _buildListItem(
                    context, null, 'Çıkış Yap', Icons.exit_to_app),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, Widget? page, String title, IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
        ),
      ),
    );
  }
}
