import 'package:flutter/material.dart';
import '../models/cart_model.dart'; // Import CartItem model
import '../viewmodels/cart_viewmodel.dart'; // Import CartViewModel
import 'payment_handling_screen.dart'; // Import PaymentHandlingScreen
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // Import JSON package

class PaymentScreen extends StatelessWidget {
  final List<CartItem> cartItems; // List of cart items

  PaymentScreen({required this.cartItems});

  Future<void> _checkout() async {
    // Calculate total amount
    int totalAmount = cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity).toInt());

    // Make a request to the backend to create a payment intent
    final response = await http.post(
      Uri.parse('http://localhost:2000/api/checkout'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': totalAmount}),
    );

    if (response.statusCode == 200) {
      // Handle successful payment intent creation
      final data = json.decode(response.body);
      // Use data['clientSecret'] for further payment processing
      print('Payment Intent created: ${data['clientSecret']}');
    } else {
      // Handle error
      print('Failed to create payment intent: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items in your cart:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Quantity: ${item.quantity} - Price: \$${item.product.price}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHandlingScreen(cartItems: cartItems), // Navigate to PaymentHandlingScreen
                  ),
                );
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
