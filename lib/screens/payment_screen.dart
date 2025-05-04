import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
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
    if (stripe.Stripe.publishableKey.isEmpty) {
      // Use stripe.Stripe
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
      await stripe.Stripe.instance.initPaymentSheet(
        // Use stripe.Stripe
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          // Use stripe.SetupPaymentSheetParameters
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ElderlyCare',
          appearance: stripe.PaymentSheetAppearance(
            // Use stripe.PaymentSheetAppearance
            colors: stripe.PaymentSheetAppearanceColors(
              primary: Colors.blue,
              background: Colors.white,
              componentBorder: Colors.grey,
              componentBackground: Colors.white,
              placeholderText: Colors.grey,
              componentText: Colors.black,
              error: Colors.red,
            ),
            shapes: stripe.PaymentSheetShape(
              borderRadius: 8.0,
              borderWidth: 1.0,
            ),
            primaryButton: stripe.PaymentSheetPrimaryButtonAppearance(
              colors: stripe.PaymentSheetPrimaryButtonTheme(
                light: stripe.PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                  text: Colors.white,
                  border: Colors.blue,
                ),
                dark: stripe.PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                  text: Colors.white,
                  border: Colors.blue,
                ),
              ),
            ),
          ),
          googlePay: stripe.PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      // Present the Payment Sheet
      await stripe.Stripe.instance.presentPaymentSheet(); // Use stripe.Stripe

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
    final themeColor = const Color.fromARGB(255, 20, 240, 189);

    return Scaffold(
      backgroundColor: themeColor, // Apply app theme color
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Section
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        // Use Material Card widget (unambiguous)
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // List of cart items
                              ...widget.cartItems.map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 24),
                              // Total Price
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '\$${getTotalPrice().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Pay Now Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _makePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}
