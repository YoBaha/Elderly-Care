import 'package:flutter/material.dart';
import '../models/product_model.dart'; // Import Product model
import '../viewmodels/cart_viewmodel.dart'; // Import CartViewModel
import '../viewmodels/item_details_viewmodel.dart'; // Import ItemDetailsViewModel

class ItemDetailsScreen extends StatelessWidget {
  final String productId;
  final String token; // Add token parameter
  final CartViewModel cartViewModel;
  final ItemDetailsViewModel viewModel = ItemDetailsViewModel();

  ItemDetailsScreen({required this.productId, required this.token})
      : cartViewModel = CartViewModel(token);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: viewModel.fetchProductDetails(productId), // Fetch product details
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final product = snapshot.data!;
          return AlertDialog(
            title: Text(product.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(product.image, height: 200), // Product image
                  SizedBox(height: 10),
                  Text('Price: \$${product.price}',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Description: ${product.description}',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await cartViewModel.addToCart(
                      product.id, 1); // Default quantity of 1
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart!')),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Add to Cart'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(), // Close the dialog
                child: Text('Close'),
              ),
            ],
          );
        }
      },
    );
  }
}
