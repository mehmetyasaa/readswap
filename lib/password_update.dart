import 'package:flutter/material.dart';
import 'package:readswap/firebase/auth.dart';

class PasswordUpdate extends StatefulWidget {
  @override
  _PasswordUpdateState createState() => _PasswordUpdateState();
}

class _PasswordUpdateState extends State<PasswordUpdate> {
  final _formKey = GlobalKey<FormState>();
  final Auth _auth = Auth();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.updatePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre başarıyla güncellendi')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre güncelleme hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7FA99B),
        title: Text('Şifreyi Güncelle'),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mevcut Şifre',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    hintText: "Mevcut Şifre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  cursorColor: const Color.fromARGB(255, 120, 120, 120),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mevcut şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Yeni Şifre',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    hintText: "Yeni Şifre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  cursorColor: const Color.fromARGB(255, 120, 120, 120),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yeni şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Yeni Şifreyi Onayla',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    hintText: "Yeni Şifreyi Onayla",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  cursorColor: const Color.fromARGB(255, 120, 120, 120),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yeni şifreyi onaylamak boş olamaz';
                    } else if (value != _newPasswordController.text) {
                      return 'Yeni şifreler eşleşmiyor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(
                        0, 150, 0, 100), // Butonun arka plan rengini belirler
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
        ),
      ),
    );
  }
}
