import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerOrderDetailPage extends StatefulWidget {
  final String orderId;

  SellerOrderDetailPage({required this.orderId});

  @override
  _SellerOrderDetailPageState createState() => _SellerOrderDetailPageState();
}

class _SellerOrderDetailPageState extends State<SellerOrderDetailPage> {
  String? selectedShippingCompany;
  TextEditingController _trackingNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .get();

      if (orderSnapshot.exists) {
        var orderData = orderSnapshot.data() as Map<String, dynamic>;
        DocumentSnapshot bookSnapshot = await orderData['Book'].get();
        DocumentSnapshot userSnapshot = await orderData['User'].get();
        DocumentSnapshot addressSnapshot = await orderData['Address'].get();

        var bookData = bookSnapshot.data() as Map<String, dynamic>;
        var userData = userSnapshot.data() as Map<String, dynamic>;
        var addressData = addressSnapshot.data() as Map<String, dynamic>;

        return {
          'order': orderData,
          'book': bookData,
          'user': userData,
          'address': addressData,
        };
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
    }
  }

  Future<void> _updateOrderStatus() async {
    try {
      String trackingNumber = _trackingNumberController.text;

      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .update({
        'OrderStatus': 'shipped',
        'ShippingCompany': selectedShippingCompany,
        'TrackingNumber': trackingNumber,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş durumu güncellendi.')),
      );
    } catch (e) {
      print('Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş durumu güncellenemedi.')),
      );
    }
  }

  Widget _buildShippingCompanyDropdown() {
    List<String> shippingCompanies = [
      'Yurtiçi Kargo',
      'MNG Kargo',
      'Aras Kargo',
      'PTT Kargo',
    ];

    return DropdownButtonFormField<String>(
      value: selectedShippingCompany,
      onChanged: (value) {
        setState(() {
          selectedShippingCompany = value;
        });
      },
      items: shippingCompanies.map((company) {
        return DropdownMenuItem<String>(
          value: company,
          child: Text(company),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Kargo Şirketi Seçin'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satıcı Sipariş Detayı'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Sipariş detayları alınamadı.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Sipariş detayları bulunamadı.'));
          }

          var order = snapshot.data!['order'];
          var book = snapshot.data!['book'];
          var user = snapshot.data!['user'];
          var address = snapshot.data!['address'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Order Information
                Card(
                  child: ListTile(
                    title: Text('Sipariş No: ${order['orderId']}'),
                    subtitle:
                        Text('Sipariş Tarihi: ${order['OrderDate'].toDate()}'),
                  ),
                ),
                SizedBox(height: 16.0),

                // Shipping Information
                _buildShippingCompanyDropdown(),
                TextField(
                  controller: _trackingNumberController,
                  decoration:
                      InputDecoration(labelText: 'Kargo Takip Numarası'),
                ),
                SizedBox(height: 16.0),

                // Update Order Status Button
                ElevatedButton(
                  onPressed: _updateOrderStatus,
                  child: Text('Kargo Bilgilerini Güncelle'),
                ),
                SizedBox(height: 16.0),

                // Product Information
                ListTile(
                  leading: Image.network(
                    book['BookImage'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(book['BookTitle']),
                  subtitle: Text('Fiyat: ${book['BookPrice']} TL'),
                ),

                // User Information
                ListTile(
                  title: Text('Alıcı Bilgileri'),
                  subtitle:
                      Text('Ad: ${user['name']}\nEmail: ${user['email']}'),
                ),
                SizedBox(height: 16.0),

                // Address Information
                ListTile(
                  title: Text('Adres Bilgileri'),
                  subtitle: Text(
                      'Adres: ${address['street']}, ${address['city']}, ${address['zip']}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
