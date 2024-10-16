import 'package:cosmos_test/app/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AddressScreen extends StatefulWidget {
  final List cartItems;
  final List<dynamic> games;
  final List<dynamic> consoles;

  AddressScreen({Key? key, required this.cartItems, required this.games, required this.consoles}) : super(key: key);

  final Dio dio = Dio();

  @override
  AddressScreenState createState() => AddressScreenState();
}

class AddressScreenState extends State<AddressScreen> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController entranceController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();

  List addressItems = [];
  List<bool> isSelectedList = [];
  bool isLoading = true;
  int isSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  Future<void> fetchAddress() async {
    try {
      final response = await Dio().get('http://192.168.0.103:8000/api/addresses');
      setState(() {
        addressItems = response.data;
        isLoading = false;
        isSelectedList = List.generate(addressItems.length, (index) => false);
      });
    } catch (e) {
      print('Error fetching address items: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Address',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF7281C6),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF7281C6)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: addressItems.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showCitySelectionModal,
              child: Text('Add address'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF7281C6),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: addressItems.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                cartItems: widget.cartItems,
                games: widget.games,
                consoles: widget.consoles,
              ),
            ),
          );
        },
        label: Text('Go to payment'),
        icon: Icon(Icons.shopping_bag_rounded),
        backgroundColor: Color(0xFF7281C6),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAddressCard(int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            isSelectedList[isSelectedIndex] = false;
            isSelectedIndex = index;
            isSelectedList[index] = true;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelectedList[index] ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Color(0xFF7281C6),
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${addressItems[index]['city']} city",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${addressItems[index]['street']}, ${addressItems[index]['houseNumber']}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editCitySelectionModal(
                  addressItems[index]['city'],
                  addressItems[index]['street'],
                  addressItems[index]['houseNumber'],
                  addressItems[index]['entrance'],
                  addressItems[index]['apartmentNumber'],
                ),
                icon: Icon(Icons.edit, color: Color(0xFF7281C6)),
              ),
              IconButton(
                onPressed: () => _deleteAddress(addressItems[index]['id']),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCitySelectionModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7281C6)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              _buildTextField(cityController, 'City'),
              _buildTextField(streetController, 'Street'),
              _buildTextField(houseNumberController, 'House number'),
              _buildTextField(entranceController, 'Entrance'),
              _buildTextField(apartmentController, 'Apartment number'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  addAddress();
                  Navigator.pop(context);
                },
                child: Text('Add address'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF7281C6),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editCitySelectionModal(String city, String street, int houseNumber, int entrance, int apartment) async {
    cityController.text = city;
    streetController.text = street;
    houseNumberController.text = houseNumber.toString();
    entranceController.text = entrance.toString();
    apartmentController.text = apartment.toString();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7281C6)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              _buildTextField(cityController, 'City'),
              _buildTextField(streetController, 'Street'),
              _buildTextField(houseNumberController, 'House number'),
              _buildTextField(entranceController, 'Entrance'),
              _buildTextField(apartmentController, 'Apartment number'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  editAddress();
                  Navigator.pop(context);
                },
                child: Text('Update address'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF7281C6),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF7281C6)),
          ),
        ),
      ),
    );
  }

  Future<void> addAddress() async {
    try {
      var response = await widget.dio.post(
        'http://192.168.0.103:8000/api/addresses',
        data: {
          'city': cityController.text,
          'street': streetController.text,
          'houseNumber': int.parse(houseNumberController.text),
          'entrance': int.parse(entranceController.text),
          'apartmentNumber': int.parse(apartmentController.text),
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAddress();
        _clearTextFields();
      } else {
        print('Failed to add address');
      }
    } catch (e) {
      print('Error adding address: $e');
    }
  }

  Future<void> editAddress() async {
    try {
      var response = await widget.dio.patch(
        'http://192.168.0.103:8000/api/addresses',
        data: {
          'city': cityController.text,
          'street': streetController.text,
          'houseNumber': int.parse(houseNumberController.text),
          'entrance': int.parse(entranceController.text),
          'apartmentNumber': int.parse(apartmentController.text),
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAddress();
        _clearTextFields();
      } else {
        print('Failed to edit address');
      }
    } catch (e) {
      print('Error editing address: $e');
    }
  }

  Future<void> _deleteAddress(int id) async {
    try {
      final response = await Dio().delete('http://192.168.0.103:8000/api/addresses/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAddress();
      }
    } catch (e) {
      print('Error deleting address item: $e');
    }
  }

  void _clearTextFields() {
    cityController.clear();
    streetController.clear();
    houseNumberController.clear();
    entranceController.clear();
    apartmentController.clear();
  }
}