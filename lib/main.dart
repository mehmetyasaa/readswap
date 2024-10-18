import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:readswap/common/color_extenstion.dart';
import 'package:readswap/old/loginpage.dart';
import 'package:readswap/old/TabView.dart';
import 'package:readswap/old/signup.dart';
import 'package:readswap/view/home/home_view.dart';

import 'old/firebase_options.dart'; // This file will contain your Firebase configuration for different platforms

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Ensure this loads the correct options for web
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      routes: {
        "/home": (context) => TabView(),
        "/login": (context) => LoginPagee(),
        "/signup": (context) => SignUpPage(),
      },
      title: 'ReadSwap',
      theme: ThemeData(
        primaryColor: TColor.primary,
      
        fontFamily: 'SF Pro Text',
        useMaterial3: true,
      ),
      home: HomeView(),
    );
  }
}
