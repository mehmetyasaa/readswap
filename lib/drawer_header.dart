import 'package:flutter/material.dart';
import 'package:readswap/firebase/auth.dart';

class HeaderDrawer extends StatefulWidget {
  const HeaderDrawer({super.key});

  @override
  State<HeaderDrawer> createState() => _HeaderDrawerState();
}

class _HeaderDrawerState extends State<HeaderDrawer> {
  String? username = "kullanıcı adı";
  String? email = Auth().getCurrentUser()!.email;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (email != null) {
      try {
        String? fetchedUsername = await Auth().getUsername();
        if (fetchedUsername != null) {
          setState(() {
            username = fetchedUsername;
            print("user mail $username");
          });
        }
      } catch (e) {
        print('Error fetching username: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double topPadding =
        deviceHeight * 0.07; // Örneğin, yüksekliğin %10'u için bir değer
    return Container(
      color: Color.fromARGB(255, 74, 143, 106),
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: deviceHeight * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage('assets/atam.jpeg')),
            ),
          ),
          Text(
            username ?? "undefined",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              email ?? "undefined",
              style: TextStyle(color: Colors.grey[200], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
