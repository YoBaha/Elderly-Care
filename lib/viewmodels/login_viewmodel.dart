import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage

class LoginViewModel extends ChangeNotifier {
  // ✅ Ensure it extends ChangeNotifier
  String email = '';
  String password = '';
  String token = ''; // Add a token field
  final FlutterSecureStorage secureStorage =
      FlutterSecureStorage(); // Initialize secure storage

  final ApiService apiService;

  LoginViewModel(this.apiService); // Fix constructor

  Future<bool> login(String email, String password) async {
    // Accept parameters
    try {
      token = await apiService.login(
          email, password); // Call the login method and get the token
      await secureStorage.write(
          key: 'token', value: token); // Store the token securely
      print('Login successful'); // Debugging statement
      notifyListeners(); // Notify listeners on successful login
      return true; // Return true on successful login
    } catch (e) {
      print('Login error: $e');
      return false; // Return false on error
    }
  }
}
