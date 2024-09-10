import 'package:flutter/material.dart';
import 'package:readswap/loginpage.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              "Skip",
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Image.asset('assets/book.png'),
          ),
          Column(
            children: [
              Text(
                "Hoşgeldiniz Kitapların Dünyasına",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                " Evinizdeki kitapları takas ederek veya satarak yeni öykülere açılan bir kapı araladınız! Sizi burada görmek bize, mutluluk veriyor. Hemen keşfetmeye başlayın ve okuma tutkunuzu daha da zenginleştirin.",
                style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 146, 146, 146)),
                textAlign: TextAlign.center,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 320),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginPagee()));
              },
              icon: Icon(Icons.arrow_right_alt),
              iconSize: 60,
              color: Color.fromARGB(255, 82, 182, 86),
            ),
          )
        ],
      ),
    );
  }
}
