import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readswap/old/service/address_controller.dart';

class AddressPage extends StatelessWidget {
  final AddressController _addressController = Get.put(AddressController());

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adreslerim'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_addressController.addressList.isEmpty) {
                return Center(child: Text('No addresses found.'));
              }
              return ListView.builder(
                itemCount: _addressController.addressList.length,
                itemBuilder: (context, index) {
                  var address = _addressController.addressList[index];
                  return ListTile(
                    title: Text(address['AddressTitle'] ?? ''),
                    subtitle: Text(
                        '${address['AddressLine1']} ${address['AddressLine2']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _titleController.text = address['AddressTitle'] ?? '';
                        _cityController.text = address['AddressCity'] ?? '';
                        _codeController.text = address['AddressCode'] ?? '';
                        _line1Controller.text = address['AddressLine1'] ?? '';
                        _line2Controller.text = address['AddressLine2'] ?? '';
                        _phoneController.text = address['AddressPhone'] ?? '';
                        _stateController.text = address['AddressState'] ?? '';
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Adres Düzenle'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _titleController,
                                  decoration:
                                      InputDecoration(labelText: 'Title'),
                                ),
                                TextField(
                                  controller: _cityController,
                                  decoration:
                                      InputDecoration(labelText: 'City'),
                                ),
                                TextField(
                                  controller: _codeController,
                                  decoration:
                                      InputDecoration(labelText: 'Code'),
                                ),
                                TextField(
                                  controller: _line1Controller,
                                  decoration: InputDecoration(
                                      labelText: 'Address Line 1'),
                                ),
                                TextField(
                                  controller: _line2Controller,
                                  decoration: InputDecoration(
                                      labelText: 'Address Line 2'),
                                ),
                                TextField(
                                  controller: _phoneController,
                                  decoration:
                                      InputDecoration(labelText: 'Phone'),
                                ),
                                TextField(
                                  controller: _stateController,
                                  decoration:
                                      InputDecoration(labelText: 'State'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  var updatedAddress = {
                                    'AddressTitle': _titleController.text,
                                    'AddressCity': _cityController.text,
                                    'AddressCode': _codeController.text,
                                    'AddressLine1': _line1Controller.text,
                                    'AddressLine2': _line2Controller.text,
                                    'AddressPhone': _phoneController.text,
                                    'AddressState': _stateController.text,
                                  };
                                  _addressController.updateAddress(
                                      address['id'], updatedAddress);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Kaydet'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: 'Code'),
                ),
                TextField(
                  controller: _line1Controller,
                  decoration: InputDecoration(labelText: 'Address Line 1'),
                ),
                TextField(
                  controller: _line2Controller,
                  decoration: InputDecoration(labelText: 'Address Line 2'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _stateController,
                  decoration: InputDecoration(labelText: 'State'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    var newAddress = {
                      'AddressTitle': _titleController.text,
                      'AddressCity': _cityController.text,
                      'AddressCode': _codeController.text,
                      'AddressLine1': _line1Controller.text,
                      'AddressLine2': _line2Controller.text,
                      'AddressPhone': _phoneController.text,
                      'AddressState': _stateController.text,
                    };
                    _addressController.addAddress(newAddress);
                    _titleController.clear();
                    _cityController.clear();
                    _codeController.clear();
                    _line1Controller.clear();
                    _line2Controller.clear();
                    _phoneController.clear();
                    _stateController.clear();
                  },
                  child: Text('Adres Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
