import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:readswap/common/color_extenstion.dart';
import 'package:readswap/old/controller/HomeController.dart';
import 'package:readswap/old/loginpage.dart';

import 'package:readswap/old/signup.dart';
import 'package:readswap/view/main_tab_view.dart/main_tab_view.dart';


import 'old/firebase_options.dart'; // This file will contain your Firebase configuration for different platforms

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Ensure this loads the correct options for web
  );
  Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      routes: {
        // "/home": (context) => TabView(),
        // "/login": (context) => LoginPagee(),
        // "/signup": (context) => SignUpPage(),
      },
      title: 'ReadSwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        primaryColor: TColor.primary,
      
        fontFamily: 'SF Pro Text',
        useMaterial3: true,
      ),
      home: const MainTabView(),
    );
  }
}
