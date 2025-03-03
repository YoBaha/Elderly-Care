import 'package:dio/dio.dart';
import '../models/product_model.dart'; // Import Product model

class ItemDetailsViewModel {
  final Dio _dio = Dio();
  final String apiUrl = "http://localhost:2000/api/products"; // Endpoint for product details

  Future<Product> fetchProductDetails(String productId) async {
    final response = await _dio.get('$apiUrl/$productId');
    return Product.fromJson(response.data); // Assuming the API returns a product object
  }
}
