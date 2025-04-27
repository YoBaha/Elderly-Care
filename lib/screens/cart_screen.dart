import 'package:flutter/material.dart';
import '../models/cart_model.dart'; // Import CartItem model
import '../viewmodels/cart_viewmodel.dart'; // Import CartViewModel
import 'payment_screen.dart'; // Import PaymentScreen

class CartScreen extends StatefulWidget {
  final String token; // Add token parameter
  CartScreen({required this.token});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartViewModel _cartViewModel;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _cartViewModel = CartViewModel(widget.token); // Initialize with token
    _loadCart();
  }

  Future<void> _loadCart() async {
    print("Fetching cart items...");
    Cart cart = await _cartViewModel.getCart();
    print("Cart items loaded: ${cart.items}");
    _cartItems = cart.items;
    setState(() {});
  }

  void _showItemOptionsDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Manage Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product: ${item.product.name}'),
              SizedBox(height: 10),
              Text('Current Quantity: ${item.quantity}'),
              SizedBox(height: 10),
              Text('Change Quantity:'),
              DropdownButton<int>(
                value: item.quantity,
                items: List.generate(10, (index) => index + 1)
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ))
                    .toList(),
                onChanged: (newValue) async {
                  if (newValue != null) {
                    await _cartViewModel.updateQuantity(
                        item.product.id, newValue);
                    await _loadCart();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _cartViewModel.removeFromCart(item.product.id);
                _loadCart();
                Navigator.pop(context);
              },
              child: Text('Remove Item'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(child: Text('Your cart is empty.'))
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.network(item.product.image,
                            width: 100, height: 100),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('Price: \$${item.product.price}',
                                  style: TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: () {
                                  _showItemOptionsDialog(item);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Quantity: ${item.quantity}'),
                                    IconButton(
                                      icon: Icon(Icons.more_horiz),
                                      onPressed: () {
                                        _showItemOptionsDialog(item);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Example of adding an item to the cart
              // _addItemToCart('example_product_id', 1);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentScreen(cartItems: _cartItems, token: widget.token),
                ),
              );
            },
            child: Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
