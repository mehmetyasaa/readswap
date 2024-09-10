import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readswap/TabView.dart';
import 'package:readswap/home_page.dart';
import 'package:readswap/firebase/auth.dart';
import 'package:readswap/loginpage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _controllerDisplayName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();

  String? errorMessage = "";
  double radius = 40;
  double fontSize = 15;

  Future<void> createUser(BuildContext context) async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
        username: _controllerDisplayName.text,
        phone: _controllerPhone.text,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TabView(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 70),
                child: Text(
                  'ReadSwap',
                  style: TextStyle(
                    color: Color(0xFF529471),
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 30,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/download.png',
                        height: 40,
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Center(
                          child: Text(
                            'Apple ID ile Giriş Yap',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 211, 211, 211),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 211, 211, 211),
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 30,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/fbLogo.png',
                        height: 40,
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Center(
                          child: Text(
                            'Facebook ile Giriş Yap',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 211, 211, 211),
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 30,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/googleLogo.png',
                        height: 40,
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          'Google ile Giriş Yap',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            const Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "E-posta İle Devam Et",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 350,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controllerDisplayName,
                      decoration: InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        prefixIcon:
                            Icon(Icons.person, color: Color(0xFF529471)),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _controllerEmail,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        prefixIcon: Icon(Icons.email, color: Color(0xFF529471)),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _controllerPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        prefixIcon:
                            const Icon(Icons.lock, color: Color(0xFF529471)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      maxLength: 11,
                      controller: _controllerPhone,
                      decoration: InputDecoration(
                        labelText: 'Telefon',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        prefixIcon:
                            const Icon(Icons.phone, color: Color(0xFF529471)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await createUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF529471),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 211, 211, 211),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: 300,
                          height: 40,
                          child: Center(
                            child: Text(
                              "Kaydol",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 236, 236, 236),
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginPagee(),
                                ),
                              );
                            },
                            child: Text("Giriş Yap"))
                      ],
                    ),
                    if (errorMessage != null && errorMessage!.isNotEmpty)
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
