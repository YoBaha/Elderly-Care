import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductViewModel {
  final Dio _dio = Dio();
  final String apiUrl =
      "http://10.0.2.2:2000/api/products"; // Correct for emulator

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _dio.get(apiUrl);
      print('Fetch products response: ${response.statusCode}');
      print('Response data: ${response.data}');
      return (response.data as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }
}
