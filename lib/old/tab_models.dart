import 'package:flutter/material.dart';
import 'package:readswap/old/CartPage.dart';
import 'package:readswap/old/home_page.dart';
import 'package:readswap/old/orderpage.dart';
import 'package:readswap/old/profile.dart';
import 'package:readswap/old/sold_book_page.dart';

class _TabModel {
  final Widget page;
  final String title;
  final Icon icon;

  _TabModel(this.page, {required this.title, required this.icon});
}

class TabModels {
  late final List<_TabModel> tabItems;

  TabModels.create() {
    tabItems = [
      _TabModel(HomePage(), icon: Icon(Icons.home_outlined), title: "Anasayfa"),
      _TabModel(CartPage(),
          icon: Icon(Icons.shopping_cart_outlined), title: "Sepet"),
      _TabModel(SoldBooksPage(),
          icon: Icon(Icons.search_outlined), title: "Ara"),
      _TabModel(ProfilePage(),
          icon: Icon(Icons.person_outline_outlined), title: "Profile"),
    ];
  }
}

//title lar widget olacak ve tab view dan kullanımına bakılacak 
//duruma göre constractor da widget olarak değiştirilecek 
