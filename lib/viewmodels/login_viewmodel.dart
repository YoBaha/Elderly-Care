import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  String token = '';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final ApiService apiService;

  LoginViewModel(this.apiService);

  Future<bool> login(String email, String password) async {
    token = await apiService.login(email, password);
    await secureStorage.write(
        key: 'auth_token', value: token); // Changed key to 'auth_token'
    print('Login successful, token: $token');
    notifyListeners();
    return true;
  }
}
