// payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/cart_model.dart';
import 'package:dio/dio.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final String token; // Add token for API calls

  PaymentScreen({required this.cartItems, required this.token});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Dio _dio = Dio();
  String? clientSecret;
  String? orderId;

  @override
  void initState() {
    super.initState();
    _createPaymentIntent();
  }

  Future<void> _createPaymentIntent() async {
    try {
      final response = await _dio.post(
        'http://localhost:2000/api/orders/create-payment-intent',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );
      setState(() {
        clientSecret = response.data['clientSecret'];
        orderId = response.data['orderId'];
      });
    } catch (e) {
      print('Failed to create payment intent: $e');
    }
  }

  Future<void> _makePayment() async {
    if (clientSecret == null) return;
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ElderlyCare',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      print('Payment successful');
      Navigator.pop(context);
    } catch (e) {
      print('Payment failed: $e');
    }
  }

  double getTotalPrice() {
    return widget.cartItems
        .fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: clientSecret == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total: \$${getTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _makePayment,
                    child: Text('Pay Now'),
                  ),
                ],
              ),
            ),
    );
  }
}
