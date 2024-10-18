import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  OrderDetailPage({required this.orderId});

  // Fetch the order details from Firestore
  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    try {
      // Fetch the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the order details using the orderId and userId
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .doc(orderId)
          .get();

      if (orderSnapshot.exists) {
        var orderData = orderSnapshot.data() as Map<String, dynamic>;

        // Assuming Book, Address, and other references are stored as Firestore document references
        DocumentReference bookRef = orderData['Book'];
        DocumentReference addressRef = orderData['Address'];
        DocumentReference sellerRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(orderData['SellerId']);

        // Fetch book data
        DocumentSnapshot bookSnapshot = await bookRef.get();
        var bookData = bookSnapshot.data() as Map<String, dynamic>;

        // Fetch address data
        DocumentSnapshot addressSnapshot = await addressRef.get();
        var addressData = addressSnapshot.data() as Map<String, dynamic>;

        // Fetch seller data (optional, depending on what you need)
        DocumentSnapshot sellerSnapshot = await sellerRef.get();
        var sellerData = sellerSnapshot.data() as Map<String, dynamic>;

        return {
          'order': orderData,
          'book': bookData,
          'address': addressData,
          'seller': sellerData, // Corrected here
        };
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
    }
  }

  // Get the download URL for the book image from Firebase Storage
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
        title: Text('Sipariş Detayı'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching order details.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Order details not found.'));
          }

          var order = snapshot.data!['order'];
          var book = snapshot.data!['book'];
          var seller = snapshot.data!['seller']; // Corrected here
          var address = snapshot.data!['address'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Order Information
                Card(
                  child: ListTile(
                    title: Text('Sipariş No: ${orderId}'),
                    subtitle: Text(
                        'Sipariş Tarihi: ${order['OrderDate'].toDate()}'),
                  ),
                ),
                SizedBox(height: 16.0),

                // Order Status
                _buildOrderStatus(order),
                SizedBox(height: 16.0),

                // Product Information
                FutureBuilder<String>(
                  future: _getDownloadUrl(book['BookImage']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Icon(Icons.error);
                    }

                    String imageUrl = snapshot.data!;
                    return ListTile(
                      leading: Image.network(imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(book['BookTitle']),
                      subtitle: Text('Fiyat: ${book['BookPrice']} TL'),
                    );
                  },
                ),

                // Seller Information (Updated)
                ListTile(
                  title: Text('Satıcı Bilgileri'),
                  subtitle: Text('Ad: ${seller['username']}\nEmail: ${seller['email']}'),
                ),
                SizedBox(height: 16.0),

                // Address Information
                ListTile(
                  title: Text('Adres Bilgileri'),
                  subtitle: Text(
                      'Adres: ${address['street']}, ${address['city']}, ${address['zip']}'),
                ),

                SizedBox(height: 16.0),

                // Action Buttons
                ElevatedButton(
                  onPressed: () {
                    // Handle return product action
                  },
                  child: Text('Ürünü İade Et'),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle support action
                  },
                  child: Text('Destek'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderStatus(Map<String, dynamic> order) {
    String orderStatus = order['OrderStatus'];

    // Set colors based on the current status
    Color receivedColor = Colors.grey;
    Color shippedColor = Colors.grey;
    Color deliveredColor = Colors.grey;
    Color completedColor = Colors.grey;

    if (orderStatus == 'received') {
      receivedColor = Colors.green;
    } else if (orderStatus == 'shipped') {
      receivedColor = Colors.green;
      shippedColor = Colors.orange;
    } else if (orderStatus == 'delivered') {
      receivedColor = Colors.green;
      shippedColor = Colors.orange;
      deliveredColor = Colors.blue;
    } else if (orderStatus == 'completed') {
      receivedColor = Colors.green;
      shippedColor = Colors.orange;
      deliveredColor = Colors.blue;
      completedColor = Colors.purple;
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.check_circle, color: receivedColor),
            title: Text('Sipariş Alındı'),
            subtitle: Text('${order['OrderDate'].toDate()}'),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping, color: shippedColor),
            title: Text('Kargolandı'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Sipariş tamamlandığında kazancın güncel para hareketlerine eklenir.'),
                Text('Bu satıştan kazancın ... RS Coin.'),
                Text('Kargo Şirketi: Yurtiçi'),
                Text('Kargo Takip No: 923189353317'),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: deliveredColor),
            title: Text('Teslim Edildi'),
          ),
          ListTile(
            leading: Icon(Icons.done_all, color: completedColor),
            title: Text('Tamamlandı'),
          ),
        ],
      ),
    );
  }
}
