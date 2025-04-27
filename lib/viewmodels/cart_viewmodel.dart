import 'package:dio/dio.dart';
import '../models/cart_model.dart';

class CartViewModel {
  final Dio _dio = Dio();
  final String apiUrl =
      "http://10.0.2.2:2000/api/carts"; // Use 10.0.2.2 for emulator
  final String token;

  CartViewModel(this.token);

  Future<Cart> getCart() async {
    try {
      final response = await _dio.get(
        apiUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print("Response from getCart: ${response.data}");
      return Cart.fromJson(response.data);
    } catch (e) {
      print('Error fetching cart: $e');
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      print('Token being sent: $token'); // Add this line
      final response = await _dio.post(
        apiUrl,
        data: {'productId': productId, 'quantity': quantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Add to cart response: ${response.statusCode}');
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final response = await _dio.put(
        '$apiUrl/$productId',
        data: {'quantity': quantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Update quantity response: ${response.statusCode}');
    } catch (e) {
      print('Error updating quantity: $e');
      throw Exception('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final response = await _dio.delete(
        '$apiUrl/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Remove from cart response: ${response.statusCode}');
    } catch (e) {
      print('Error removing from cart: $e');
      throw Exception('Error removing from cart: $e');
    }
  }
}
