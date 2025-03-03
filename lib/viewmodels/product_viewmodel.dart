import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductViewModel {
  final Dio _dio = Dio();
  final String apiUrl = "http://localhost:2000/api/products"; // Updated to use localhost




  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get(apiUrl);
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }
}
