import 'package:flutter/material.dart';
import 'package:readswap/drawer_header.dart';
import 'package:readswap/firebase/auth.dart';
import 'package:readswap/first_page.dart';
import 'package:readswap/form_list_screen.dart';
import 'package:readswap/loginpage.dart';
import 'package:readswap/privacyPolicy.dart';
import 'package:readswap/product_add_page.dart';
import 'package:readswap/settings.dart';
import 'package:readswap/tab_models.dart';
import 'package:readswap/ProfileUpdate.dart'; // Import the SettingsPage

class TabView extends StatelessWidget {
  TabView({Key? key}) : super(key: key);

  final _items = TabModels.create().tabItems;
  var currentPage = DrawerSections.kategoriler;

  @override
  Widget build(BuildContext context) {
    final String userMail =
        ModalRoute.of(context)?.settings.arguments as String? ??
            'default@example.com';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          shape: CircleBorder(),
          tooltip: 'Increment',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ForumListScreen(),
              ),
            );
          },
          child: Image.asset(
            "assets/homebutton.png",
          ),
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  HeaderDrawer(),
                  MyDrawerList(context),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductAdd()));
                },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                ),
              ),
            )
          ],
          title: Text(
            'ReadSwap',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 30,
              fontWeight: FontWeight.w400,
              letterSpacing: 6,
            ),
          ),
        ),
        body: TabBarView(
          children: _items.map((e) => e.page).toList(),
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 5,
          shape: const CircularNotchedRectangle(),
          color: Color.fromARGB(255, 243, 243, 243),
          child: TabBar(
            indicator: BoxDecoration(),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: _items.map((e) => Tab(text: e.title, icon: e.icon)).toList(),
          ),
        ),
      ),
    );
  }

  Widget MyDrawerList(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(context, 1, "Kategoriler", Icons.dashboard_outlined),
          menuItem(context, 2, "Kampanyalar", Icons.local_offer_outlined),
          menuItem(context, 3, "Kaydedilenler", Icons.book_outlined),
          menuItem(
              context, 4, "Gizlilik Politikası", Icons.privacy_tip_outlined),
          menuItem(
              context, 5, "Yardım ve Destek", Icons.question_mark_outlined),
          menuItem(context, 6, "Ayarlar", Icons.settings_outlined),
          menuItem(context, 7, "Çıkış Yap", Icons.exit_to_app),
        ],
      ),
    );
  }

  Widget menuItem(BuildContext context, int id, String title, IconData icon) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (id == 1) {
            currentPage = DrawerSections.kategoriler;
          } else if (id == 2) {
            currentPage = DrawerSections.kampanyalar;
          } else if (id == 3) {
            currentPage = DrawerSections.kaydedilenler;
          } else if (id == 4) {
            currentPage = DrawerSections.gizlilikPolitikasi;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
            );
          } else if (id == 5) {
            currentPage = DrawerSections.yardimDestek;
          } else if (id == 6) {
            currentPage = DrawerSections.ayarlar;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          } else if (id == 7) {
            currentPage = DrawerSections.ayarlar;
            Auth().signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPagee()),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawerSections {
  kategoriler,
  kampanyalar,
  kaydedilenler,
  gizlilikPolitikasi,
  yardimDestek,
  ayarlar,
}
