import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // Import JSON package
import '../models/cart_model.dart'; // Import CartItem model

class PaymentHandlingScreen extends StatefulWidget {
  final List<CartItem> cartItems; // List of cart items

  PaymentHandlingScreen({required this.cartItems});

  @override
  _PaymentHandlingScreenState createState() => _PaymentHandlingScreenState();
}

class _PaymentHandlingScreenState extends State<PaymentHandlingScreen> {
  double totalAmount = 0.0;
  String selectedPaymentMethod = 'cash_on_delivery'; // Default payment method
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardInfoController = TextEditingController();
  final TextEditingController paypalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    totalAmount = widget.cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  Future<void> _checkout() async {
    // Prepare payment data based on selected method
    Map<String, dynamic> paymentData = {
      'amount': totalAmount,
      'payment_method': selectedPaymentMethod,
    };

    if (selectedPaymentMethod == 'cash_on_delivery') {
      paymentData['shipping_address'] = addressController.text;
    } else if (selectedPaymentMethod == 'paypal') {
      paymentData['paypal_info'] = paypalInfoController.text;
    } else if (selectedPaymentMethod == 'credit_card') {
      paymentData['card_info'] = cardInfoController.text;
    }

    // Make a request to the backend to create a payment intent
    final response = await http.post(
      Uri.parse('http://localhost:2000/api/checkout'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(paymentData),
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
        title: Text('Billing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('Select Payment Method:', style: TextStyle(fontSize: 18)),
            ListTile(
              title: Text('Cash on Delivery'),
              leading: Radio(
                value: 'cash_on_delivery',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value.toString();
                  });
                },
              ),
            ),
            ListTile(
              title: Text('PayPal'),
              leading: Radio(
                value: 'paypal',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value.toString();
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Credit Card'),
              leading: Radio(
                value: 'credit_card',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value.toString();
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            if (selectedPaymentMethod == 'cash_on_delivery') 
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Shipping Address'),
              ),
            if (selectedPaymentMethod == 'paypal' || selectedPaymentMethod == 'credit_card') 
              Column(
                children: [
                  TextField(
                    controller: selectedPaymentMethod == 'paypal' ? paypalInfoController : cardInfoController,
                    decoration: InputDecoration(labelText: selectedPaymentMethod == 'paypal' ? 'PayPal Info' : 'Card Info'),
                  ),
                  if (selectedPaymentMethod == 'credit_card') ...[
                    TextField(
                      decoration: InputDecoration(labelText: 'Expiration Date'),
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'CVV'),
                    ),
                  ],
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement payment processing logic here
                // Example: Call the _checkout method to process the payment
                _checkout();
              },
              child: Text('Confirm Payment'),

            ),
          ],
        ),
      ),
    );
  }
}
