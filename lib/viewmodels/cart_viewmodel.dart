import 'package:dio/dio.dart';
import '../models/cart_model.dart';

class CartViewModel {
  Future<void> removeFromCart(String productId) async {
    // Implement the logic to remove the item from the cart
    await _dio.delete('$apiUrl/$productId'); // Assuming the API supports DELETE requests
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    // Implement the logic to update the quantity of the item in the cart
    await _dio.put('$apiUrl/$productId', data: {
      'quantity': quantity,
    });
  }

  final Dio _dio = Dio();
  final String apiUrl = "http://localhost:2000/api/carts"; // Updated to use the correct endpoint




  Future<Cart> getCart() async {

    // Fetch the cart items for the specified user

    final response = await _dio.get('$apiUrl', options: Options(headers: {'Authorization': 'token'}));
    print("Response from getCart: ${response.data}"); // Log the response data


    return Cart.fromJson(response.data);
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      // Attempt to add the item to the cart
      await _dio.post(apiUrl, data: {

        'productId': productId,
        'quantity': quantity
      });
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 404) {
          print("Error: The endpoint for adding to cart was not found.");
        } else {
          print("Error adding to cart: ${e.response?.statusCode} - ${e.response?.statusMessage}");
        }
      } else {
        print("Error adding to cart: $e");
      }
    }

  }
}
