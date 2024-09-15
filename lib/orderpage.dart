import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:readswap/orderDetailsPage.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

Future<List<Map<String, dynamic>>> _fetchOrders() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the Orders subcollection from the current user's document in the Users collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Orders') // Access the Orders subcollection
        .get();

    List<Map<String, dynamic>> orders = [];

    for (var doc in querySnapshot.docs) {
      var orderData = doc.data() as Map<String, dynamic>;
      DocumentReference bookRef = orderData['Book'];
      DocumentSnapshot bookSnapshot = await bookRef.get();

      if (bookSnapshot.exists) {
        var bookData = bookSnapshot.data() as Map<String, dynamic>;
        orders.add({
          'orderId': doc.id,
          'orderDate': orderData['OrderDate'],
          'bookTitle': bookData['BookTitle'],
          'bookImage': bookData['BookImage'],
        });
      }
    }

    return orders;
  } catch (e) {
    print('Error fetching orders: $e');
    return [];
  }
}

  Future<String> _getDownloadUrl(String gsUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching download URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Siparişlerim'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Orders'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return ListTile(
                leading: FutureBuilder<String>(
                  future: _getDownloadUrl(order['bookImage']),
                  builder: (context, urlSnapshot) {
                    if (urlSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (urlSnapshot.hasError ||
                        !urlSnapshot.hasData ||
                        urlSnapshot.data!.isEmpty) {
                      return Icon(Icons.error);
                    }

                    String imageUrl = urlSnapshot.data!;
                    return Image.network(imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover);
                  },
                ),
                title: Text(order['bookTitle']),
                subtitle: Text('Order Date: ${order['orderDate'].toDate()}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailPage(orderId: order['orderId']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
