import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readswap/firebase/auth.dart';

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
      home: ProfileUpdate(),
    );
  }
}

class ProfileUpdate extends StatefulWidget {
  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  final _formKey = GlobalKey<FormState>();
  final Auth _auth = Auth();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() async {
    Map<String, dynamic>? userData = await _auth.getUserData();
    if (userData != null) {
      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _emailController.text = userData['email'] ?? '';
      });
    }
  }

  void _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.updateUserData(
          username: _usernameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil başarıyla güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7FA99B),
        title: Text('Profili Düzenle'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 85,
                        backgroundImage: AssetImage('assets/atam.jpeg'),
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Kullanıcı Adı',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        hintText: "Kullanıcı Adı",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.person),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      cursorColor: const Color.fromARGB(255, 120, 120, 120),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kullanıcı adı boş olamaz';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Telefon Numarası',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        hintText: "Telefon Numarası",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.phone_sharp),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      cursorColor: const Color.fromARGB(255, 120, 120, 120),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Telefon numarası boş olamaz';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'E-posta',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        hintText: "E-posta",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.mark_email_read_sharp),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      cursorColor: const Color.fromARGB(255, 120, 120, 120),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-posta boş olamaz';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(0, 150, 0,
                            100), // Butonun arka plan rengini belirler
                      ),
                      child: Text(
                        'Güncelle',
                        style: TextStyle(
                          fontSize: 20,
                          backgroundColor: Color.fromRGBO(
                              0, 150, 0, 100), // Metin arka plan rengi
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
