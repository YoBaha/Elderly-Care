import '../services/api_service.dart';
import '../models/product_model.dart'; // Import the Product model
import '../services/notification_service.dart'; // Import NotificationService

// Import the Product model

class MarketplaceViewModel {
  final ApiService _apiService;

  MarketplaceViewModel(String token, NotificationService notificationService)
      : _apiService = ApiService(token, notificationService);

  Future<List<Product>> fetchProducts() async {
    try {
      final products = await _apiService.getProducts();
      return products;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}
