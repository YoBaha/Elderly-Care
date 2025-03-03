import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product_model.dart';
import 'notification_service.dart';
import '../models/doctor.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.17:2000/api';
  String token; // Changed from final to allow token updates
  final int timeoutSeconds = 30;
  final int maxRetries = 2;
  final NotificationService notificationService;

  ApiService(this.token, this.notificationService);

  void updateToken(String newToken) {
    token = newToken;
  }

  Future<http.Response> _makeRequest(
      Future<http.Response> Function() request) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response =
            await request().timeout(Duration(seconds: timeoutSeconds));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        print(
            'Request failed (attempt ${attempt + 1}): ${response.statusCode}');
      } catch (e) {
        print('Request error (attempt ${attempt + 1}): $e');
      }
      attempt++;
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: 2));
      }
    }
    throw Exception('Request failed after $maxRetries attempts');
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Doctor-related methods
  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/doctors/getD'),
            headers: _getHeaders(),
          ));

      print('Raw response data: ${response.body}');
      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is! List) {
          throw Exception('Invalid response format: Expected array of doctors');
        }

        return decodedBody.map<Doctor>((doctor) {
          try {
            return Doctor.fromJson(doctor);
          } catch (e) {
            print(
                'Error parsing doctor data: $e\nDoctor data: ${json.encode(doctor)}');
            throw Exception('Invalid doctor data: ${e.toString()}');
          }
        }).toList();
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      throw Exception('Failed to fetch doctors: ${e.toString()}');
    }
  }

  Future<List<Doctor>> getNearbyDoctors(List<double> location) async {
    final response = await _makeRequest(() => http.get(
          Uri.parse(
              '$baseUrl/doctors/nearby?lat=${location[1]}&lng=${location[0]}'),
          headers: _getHeaders(),
        ));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((doctor) => Doctor.fromJson(doctor)).toList();
    } else {
      throw Exception('Failed to load nearby doctors');
    }
  }

  Future<Doctor> getDoctorById(String id) async {
    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/doctors/$id'),
          headers: _getHeaders(),
        ));

    if (response.statusCode == 200) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load doctor details');
    }
  }

  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/doctors/getD?specialization=$specialization'),
            headers: _getHeaders(),
          ));

      print("Fetching doctors by specialization for: $specialization");
      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is! List) {
          throw Exception('Invalid response format: Expected array of doctors');
        }

        return decodedBody
            .map<Doctor>((doctor) => Doctor.fromJson(doctor))
            .toList();
      } else {
        throw Exception(
            'Failed to load doctors by specialization: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching doctors by specialization: $e');
      throw Exception(
          'Failed to fetch doctors by specialization: ${e.toString()}');
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      final response = await _makeRequest(() => http.delete(
            Uri.parse('$baseUrl/doctors/$id'),
            headers: _getHeaders(),
          ));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete doctor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting doctor: $e');
      throw Exception('Failed to delete doctor: $e');
    }
  }

  // Existing product and user methods
  Future<List<Product>> getProducts() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/products'),
            headers: _getHeaders(),
          ));

      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<String> signup(User user) async {
    try {
      final response = await _makeRequest(() => http.post(
            Uri.parse('$baseUrl/users/register'),
            headers: _getHeaders(),
            body: json.encode(user.toJson()),
          ));

      final data = json.decode(response.body);
      return data['token'];
    } catch (e) {
      print('Error during signup: $e');
      throw Exception('Failed to signup: $e');
    }
  }

  Future<String> login(String email, String password) async {
    try {
      print('Attempting to log in with email: $email');
      final response = await _makeRequest(() => http.post(
            Uri.parse('$baseUrl/users/login'),
            headers: _getHeaders(),
            body: json.encode({'email': email, 'password': password}),
          ));

      final data = json.decode(response.body);
      final token = data['token'];

      String quote = await fetchMotivationalQuote();
      await notificationService.showNotification('Motivational Quote', quote);

      return token;
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> getUser() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/users/profile-details'),
            headers: _getHeaders(),
          ));

      return User.fromJson(json.decode(response.body));
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      await _makeRequest(() => http.put(
            Uri.parse('$baseUrl/users/profile-update'),
            headers: _getHeaders(),
            body: json.encode(user.toJson()),
          ));
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<String> fetchMotivationalQuote() async {
    try {
      final response =
          await http.get(Uri.parse('https://qapi.vercel.app/api/random'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = data['quote'];
        await notificationService.showNotification('Motivational Quote', quote);
        return quote;
      } else {
        return 'Every day is a new opportunity to grow and improve.';
      }
    } catch (e) {
      return 'Challenges are what make life interesting. Overcoming them is what makes life meaningful.';
    }
  }

  Future<void> showQuoteOnAppLaunch() async {
    try {
      String quote = await fetchMotivationalQuote();
      await notificationService.showNotification('Motivational Quote', quote);
    } catch (e) {
      print('Error showing quote on app launch: $e');
    }
  }
}
