import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product_model.dart';
import 'notification_service.dart';
import '../models/doctor.dart';
import '../models/exercise.dart';

class ApiService {
  String get baseUrl {
    if (kIsWeb) {
      // For web, use localhost or your machine's IP
      return 'http://localhost:2000/api';
      // Alternatively, use 'http://192.168.1.14:2000/api' if accessing from another device
    } else if (Platform.isAndroid && _isEmulator()) {
      // For Android emulator, use 10.0.2.2
      return 'http://10.0.2.2:2000/api';
    } else {
      // For physical devices or other platforms (iOS, desktop), use local IP or server URL
      return 'http://192.168.1.14:2000/api';
      // Replace with your server's public IP or domain if hosted externally
    }
  }

  String token;
  final int timeoutSeconds = 30;
  final int maxRetries = 2;
  final NotificationService? notificationService;
  static const String exercisesApiKey =
      'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
  static const String sudokuApiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';

  ApiService(this.token, this.notificationService);

  // Detect if running on an Android emulator
  bool _isEmulator() {
    // Emulator detection based on device properties
    // This is a basic check; refine as needed
    return Platform.isAndroid &&
        (Platform.environment['ANDROID_EMULATOR'] != null ||
            RegExp(r'^emulator-')
                .hasMatch(Platform.environment['ANDROID_MODEL'] ?? ''));
  }

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
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token'
    };
  }

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

  Future<List<Product>> getProducts() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/products'),
            headers: {
              'Content-Type': 'application/json',
            },
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
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    try {
      print('Attempting to log in with email: $email');
      final response = await _makeRequest(() => http.post(
            Uri.parse('$baseUrl/users/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          ));

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = json.decode(response.body);
      print('Parsed response data: $data');

      final token = data['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Invalid token received from server');
      }
      if (!token.contains('.')) {
        throw Exception('Malformed token received');
      }

      updateToken(token);

      return token;
    } on http.ClientException catch (e) {
      print('Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      print('Invalid server response: ${e.message}');
      throw Exception('Invalid server response: ${e.message}');
    } catch (e) {
      print('Login failed: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> getUser() async {
    if (token.isEmpty) {
      throw Exception('Token is not available');
    }
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
        return data['quote'];
      }
      return 'Every day is a new opportunity to grow and improve.';
    } catch (e) {
      return 'Challenges are what make life interesting. Overcoming them is what makes life meaningful.';
    }
  }

  Future<void> showQuoteOnAppLaunch() async {
    try {
      String quote = await fetchMotivationalQuote();
      if (notificationService != null) {
        await notificationService!
            .showNotification('Motivational Quote', quote);
      } else {
        print('NotificationService not available, skipping notification');
      }
    } catch (e) {
      print('Error showing quote on app launch: $e');
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/carts'),
            headers: _getHeaders(),
          ));
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await _makeRequest(() => http.post(
            Uri.parse('$baseUrl/carts'),
            headers: _getHeaders(),
            body: json.encode({'productId': productId, 'quantity': quantity}),
          ));
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    try {
      await _makeRequest(() => http.put(
            Uri.parse('$baseUrl/carts/$productId'),
            headers: _getHeaders(),
            body: json.encode({'quantity': quantity}),
          ));
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _makeRequest(() => http.delete(
            Uri.parse('$baseUrl/carts/$productId'),
            headers: _getHeaders(),
          ));
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<List<Exercise>> fetchExercises({
    String? name,
    String? type,
    String? muscle,
    String? difficulty,
  }) async {
    final Map<String, String> queryParams = {};
    if (name != null) queryParams['name'] = name;
    if (type != null) queryParams['type'] = type;
    if (muscle != null) queryParams['muscle'] = muscle;
    if (difficulty != null) queryParams['difficulty'] = difficulty;

    final uri = Uri.parse('https://api.api-ninjas.com/v1/exercises')
        .replace(queryParameters: queryParams);

    final response = await _makeRequest(() => http.get(
          uri,
          headers: {
            'X-Api-Key': exercisesApiKey,
            'Content-Type': 'application/json',
          },
        ));

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is List) {
        return decodedBody.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: Expected array of exercises');
      }
    } else {
      throw Exception('Failed to load exercises: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchSudokuPuzzle({
    int? width,
    int? height,
    String? difficulty,
    String? seed,
  }) async {
    final Map<String, String> queryParams = {};
    if (width != null) queryParams['width'] = width.toString();
    if (height != null) queryParams['height'] = height.toString();
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    if (seed != null) queryParams['seed'] = seed;

    final uri = Uri.parse('https://api.api-ninjas.com/v1/sudokugenerate')
        .replace(queryParameters: queryParams);

    final response = await _makeRequest(() => http.get(
          uri,
          headers: {
            'X-Api-Key': sudokuApiKey,
            'Content-Type': 'application/json',
          },
        ));

    if (response.statusCode == 200) {
      print('Sudoku API Response: ${response.body}');
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      } else {
        throw Exception(
            'Invalid response format: Expected a Sudoku puzzle object');
      }
    } else {
      throw Exception('Failed to load Sudoku puzzle: ${response.statusCode}');
    }
  }
}
