import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:readswap/first_page.dart';
import 'package:readswap/loginpage.dart';
import 'package:readswap/TabView.dart';
import 'package:readswap/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPagee(),
    );
  }
}
