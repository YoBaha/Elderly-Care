import 'package:flutter/material.dart';
import '../models/product_model.dart'; // Import Product model
import 'item_details_screen.dart'; // Import ItemDetailsScreen


import '../viewmodels/marketplace_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart'; // Import CartViewModel
import 'cart_screen.dart'; // Import CartScreen

import '../services/notification_service.dart'; // Import NotificationService

class MarketplaceScreen extends StatelessWidget {
  final MarketplaceViewModel viewModel;
  final CartViewModel cartViewModel; // Instantiate CartViewModel

  MarketplaceScreen(String token, NotificationService notificationService)
      : viewModel = MarketplaceViewModel(token, notificationService),
        cartViewModel = CartViewModel(); // Initialize CartViewModel

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'), // Updated title to Articles
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart), // Add cart icon
                      onPressed: () {
                        // Open cart as a half-screen
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.75, // Half screen height
                              child: CartScreen(), // Assuming CartScreen is the widget for the cart
                            );
                          },
                        );
                      },

          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: viewModel.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final products = snapshot.data ?? []; // Handle null case

            // Example of popular articles
            final popularArticles = ['Covid-19', 'Diet', 'Fitness']; // Remove duplicates
            final uniquePopularArticles = popularArticles.toSet().toList(); // Ensure uniqueness


            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                childAspectRatio: 0.75, // Adjust the aspect ratio as needed
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              

              itemCount: products.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(products[index]?.name ?? 'Unknown Product'),
                      subtitle: Text('\$${products[index]?.price ?? 0}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsScreen(productId: products[index].id),

                          ),
                        );
                      },

                    ),
                    // Add a horizontal scroll for trending articles
                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: uniquePopularArticles.length,

                        itemBuilder: (context, index) {
                          return Card(
                            child: Container(
                              width: 150,
                              child: Column(
                                children: [
                                  Text(uniquePopularArticles[index]),

                                  // Placeholder for article thumbnail
                                  Container(
                                    height: 60,
                                    color: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, Product product) {
    // Add a quantity selector
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to Cart'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How many "${product.name}" would you like to add?'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) {
                      quantity--;
                    }
                  },
                ),
                Text('$quantity'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    quantity++;
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await cartViewModel.addToCart(product.id, quantity);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to cart!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add to cart: $e')),
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added to cart!')),
              );
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
