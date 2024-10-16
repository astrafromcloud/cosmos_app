import 'package:cosmos_test/app/screens/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CartScreen extends StatefulWidget {
  final List<dynamic> games;
  final List<dynamic> consoles;

  const CartScreen({Key? key, required this.games, required this.consoles})
      : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  final Dio _dio = Dio();
  final String _baseUrl = 'http://192.168.0.103:8000/api';

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      final response = await _dio.get('$_baseUrl/carts');
      setState(() {
        cartItems = response.data;
        isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error fetching cart items: $e');
    }
  }

  Future<void> deleteAllCarts() async {
    try {
      final response = await _dio.delete('$_baseUrl/carts/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          cartItems.clear();
        });
        _showSuccessSnackBar('All items deleted successfully!');
      } else {
        _showErrorSnackBar('Failed to delete all items');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting all cart items: $e');
    }
  }

  Future<void> deleteCartItem(int id) async {
    try {
      final response = await _dio.delete('$_baseUrl/carts/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart();
        _showSuccessSnackBar('Item deleted successfully!');
      } else {
        _showErrorSnackBar('Failed to delete item');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting cart item: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Shopping Cart'),
      //   actions: [
      //     if (cartItems.isNotEmpty)
      //       IconButton(
      //         icon: const Icon(Icons.delete_sweep),
      //         onPressed: deleteAllCarts,
      //         tooltip: 'Delete All Items',
      //       ),
      //   ],
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) =>
                      _buildCartItem(cartItems[index]),
                ),
      floatingActionButton: cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF7281C6),
              onPressed: () => _navigateToAddressScreen(),
              label: const Text('Proceed to Order'),
              icon: const Icon(Icons.shopping_bag_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCartItem(dynamic item) {
    final bool isGame = item['game_id'] != null;
    final dynamic product = isGame
        ? widget.games[item['game_id'] - 1]
        : widget.consoles[item['console_id'] - 1];

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(
          product['image'],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          product['name'],
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF7281C6)),
        ),
        subtitle: Text(
          '${product['price']} ₸',
          style: const TextStyle(color: Color(0xFF7281C6)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => deleteCartItem(item['id']),
        ),
      ),
    );
  }

  void _navigateToAddressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(
          cartItems: cartItems,
          games: widget.games,
          consoles: widget.consoles,
        ),
      ),
    );
  }
}
