import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/cart_model.dart';
import 'package:dio/dio.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final String token;

  PaymentScreen({required this.cartItems, required this.token});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Dio _dio = Dio();
  String? clientSecret;
  String? orderId;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ensure Stripe is initialized (should be done in main.dart, but verify here)
    if (Stripe.publishableKey.isEmpty) {
      // Changed to Stripe.publishableKey
      print('Stripe publishable key not set. Please initialize in main.dart.');
      setState(() {
        errorMessage = 'Payment configuration error. Please try again later.';
        isLoading = false;
      });
      return;
    }
    _createPaymentIntent();
  }

  Future<void> _createPaymentIntent() async {
    try {
      // Prepare cart data to send to backend
      final cartData = widget.cartItems
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final response = await _dio.post(
        'http://10.0.2.2:2000/api/orders/create-payment-intent',
        data: {'items': cartData},
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      setState(() {
        clientSecret = response.data['clientSecret'];
        orderId = response.data['orderId'];
        isLoading = false;
      });
    } catch (e) {
      print('Failed to create payment intent: $e');
      setState(() {
        errorMessage = 'Failed to initialize payment. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _makePayment() async {
    if (clientSecret == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment not ready. Please try again.')),
      );
      return;
    }
    try {
      // Initialize the Payment Sheet with appearance settings
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ElderlyCare',
          // Add appearance configuration to avoid theme errors
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
              background: Colors.white,
              componentBorder: Colors.grey,
              componentBackground: Colors.white,
              placeholderText: Colors.grey,
              componentText: Colors.black,
              error: Colors.red,
            ),
            shapes: PaymentSheetShape(
              borderRadius: 8.0,
              borderWidth: 1.0,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                  text: Colors.white,
                  border: Colors.blue,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                  text: Colors.white,
                  border: Colors.blue,
                ),
              ),
            ),
          ),
          // Explicitly set Google Pay or Apple Pay if needed (optional)
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true, // Set to false in production
          ),
        ),
      );

      // Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Payment failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child:
                      Text(errorMessage!, style: TextStyle(color: Colors.red)))
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
