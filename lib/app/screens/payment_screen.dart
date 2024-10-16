import 'package:cosmos_test/app/screens/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PaymentScreen extends StatefulWidget {
  final List<dynamic> games;
  final List<dynamic> consoles;
  final List cartItems;

  const PaymentScreen({
    Key? key,
    required this.cartItems,
    required this.games,
    required this.consoles,
  }) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  bool isPromoCodeValid = false;
  bool isPromoCodeChecked = false;
  double discountPercentage = 0.0;
  final TextEditingController promoCodeController = TextEditingController();
  final Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7281C6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) => _buildCartItem(index),
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Total: ${_formatCurrency(_calculateTotal())}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isPromoCodeValid)
                    Text(
                      "Discounted Total: ${_formatCurrency(_calculateDiscountedTotal())}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildPromoCodeField(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.cartItems.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _placeOrder,
        label: const Text('Place Order'),
        icon: const Icon(Icons.shopping_bag_rounded),
        backgroundColor: const Color(0xFF7281C6),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCartItem(int index) {
    final item = widget.cartItems[index];
    final isGame = item['game_id'] != null;
    final product = isGame
        ? widget.games[item['game_id'] - 1]
        : widget.consoles[item['console_id'] - 1];

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(
          product['image'],
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          product['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF7281C6),
          ),
        ),
        subtitle: Text(
          _formatCurrency(product['price']),
          style: const TextStyle(color: Color(0xFF7281C6)),
        ),
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: promoCodeController,
            decoration: InputDecoration(
              labelText: 'Promo Code',
              errorText: isPromoCodeChecked && !isPromoCodeValid
                  ? 'Invalid promo code'
                  : null,
              errorStyle: const TextStyle(color: Colors.red),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isPromoCodeChecked
                      ? (isPromoCodeValid ? Colors.green : Colors.red)
                      : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isPromoCodeChecked
                      ? (isPromoCodeValid ? Colors.green : Colors.red)
                      : const Color(0xFF7281C6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _checkPromoCode(promoCodeController.text),
          child: const Text('Apply'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7281C6),
          ),
        ),
      ],
    );
  }

  void _placeOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    );
  }

  String _formatCurrency(dynamic amount) {
    return '${amount.toStringAsFixed(2)}₸';
  }

  double _calculateTotal() {
    return widget.cartItems.fold(0.0, (sum, item) {
      final product = item['game_id'] != null
          ? widget.games[item['game_id'] - 1]
          : widget.consoles[item['console_id'] - 1];
      return sum + product['price'];
    });
  }

  double _calculateDiscountedTotal() {
    final total = _calculateTotal();
    return total - (total * discountPercentage);
  }

  Future<void> _checkPromoCode(String code) async {
    try {
      final response = await dio.get(
        'http://192.168.0.103:8000/api/promotions/code',
        queryParameters: {'code': code},
      );

      print(response.data);

      setState(() {
        isPromoCodeChecked = true;
        if (response.data.toString() == "1") {
          isPromoCodeValid = true;
        } else {
          isPromoCodeValid = false;
        }
        discountPercentage = isPromoCodeValid ? 0.1 : 0.0;
      });

      print(isPromoCodeValid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPromoCodeValid
                ? 'Promo code applied successfully! 10% discount added.'
                : 'Invalid promo code. Please try again.',
          ),
          backgroundColor: isPromoCodeValid ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('Error checking promo code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error checking promo code. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}