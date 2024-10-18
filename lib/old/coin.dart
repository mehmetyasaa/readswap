import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinBalancePage extends StatefulWidget {
  @override
  _CoinBalancePageState createState() => _CoinBalancePageState();
}

class _CoinBalancePageState extends State<CoinBalancePage> {
  late Future<Map<String, dynamic>> _coinDataFuture;
  TextEditingController _coinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coinDataFuture = _fetchCoinData();
  }

  Future<Map<String, dynamic>> _fetchCoinData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      var userData = userSnapshot.data() as Map<String, dynamic>;

      double coinBalance = userData['coins'] ?? 0.0;

      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('User',
              isEqualTo:
                  FirebaseFirestore.instance.collection('Users').doc(userId))
          .get();

      double coinsSpent = 0.0;
      double coinsEarned = 0.0;

      for (var doc in orderSnapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;
        DocumentReference bookRef = orderData['Book'];
        DocumentSnapshot bookSnapshot = await bookRef.get();

        if (bookSnapshot.exists) {
          var bookData = bookSnapshot.data() as Map<String, dynamic>;
          double bookPrice = double.parse(bookData['BookPrice']);

          if (orderData['User'].id == userId) {
            coinsSpent += bookPrice;
          }

          if (bookData['UserId'].id == userId) {
            coinsEarned += bookPrice;
          }
        }
      }

      return {
        'coinBalance': coinBalance,
        'coinsSpent': coinsSpent,
        'coinsEarned': coinsEarned,
      };
    } catch (e) {
      print('Error fetching coin data: $e');
      return {};
    }
  }

  void _navigateToBuyCoinsPage(double coinAmount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyCoinsPage(coinAmount: coinAmount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ReadSwap Coin'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _coinDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Data Available'));
          }

          var coinData = snapshot.data!;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildBalanceCard(coinData),
                  SizedBox(height: 20),
                  Text(
                    "Coin Satın Al",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildCoinOption(50),
                      _buildCoinOption(100),
                      _buildCoinOption(200),
                      _buildCoinOption(300),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _coinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Diğer Tutar',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      double coinAmount =
                          double.tryParse(_coinController.text) ?? 0;
                      if (coinAmount > 0) {
                        _navigateToBuyCoinsPage(coinAmount);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Geçerli bir miktar girin")),
                        );
                      }
                    },
                    child: Text("Satın Al"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, dynamic> coinData) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      child: Image.asset('assets/homebutton.png'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'RsCoin',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Icon(Icons.info_outline, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 80),
                      child: Text(
                        "Bakiye",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${coinData['coinBalance']} RsCoin',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  '~ ${coinData['coinBalanceTL']} TL',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text("Beklemede",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 68, 68, 68))),
                    ),
                    Text(
                      '${coinData['secondaryCoinBalance']} RsCoin',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 85, 85, 85)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 70.0),
                      child: Text(
                        '~ ${coinData['secondaryCoinBalanceTL']} TL',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harcanan Coin: ${coinData['coinsSpent']} RsCoin',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Kazanılan Coin: ${coinData['coinsEarned']} RsCoin',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinOption(int amount) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          _navigateToBuyCoinsPage(amount.toDouble());
        },
        child: Text("$amount"),
      ),
    );
  }
}

class BuyCoinsPage extends StatelessWidget {
  final double coinAmount;

  BuyCoinsPage({required this.coinAmount});

  void _buyCoins(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        double currentCoins = userData['coins'] ?? 0.0;
        double newCoinBalance = currentCoins + coinAmount;
        transaction.update(userRef, {'coins': newCoinBalance});
      }
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$coinAmount RsCoin successfully purchased!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase coins: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satın Al RsCoin'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _buyCoins(context),
          child: Text("Al $coinAmount RsCoin"),
        ),
      ),
    );
  }
}
