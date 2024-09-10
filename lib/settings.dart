import 'package:flutter/material.dart';
import 'package:readswap/password_update.dart';
import 'package:readswap/profile_update.dart';

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
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7FA99B),
        title: Text('Ayarlar'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
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
                    child: Text(
                      "Mehmet Yaşa",
                      style: TextStyle(fontSize: 20, color: Colors.white),
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
                    context, 'Profili Düzenle', Icons.edit, ProfileUpdate()),
                SizedBox(height: 10),
                _buildListItem(context, 'Şifre Değişikliği',
                    Icons.password_rounded, PasswordUpdate()),
                SizedBox(height: 10),
                _buildListItem(
                    context, 'Kartlarım', Icons.credit_card, ProfileUpdate()),
                SizedBox(height: 10),
                _buildListItem(context, 'Yardım ve Destek',
                    Icons.help_outline_outlined, ProfileUpdate()),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, String title, IconData icon, Widget nextPage) {
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
            if (nextPage != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => nextPage),
              );
            }
          },
        ),
      ),
    );
  }
}
