import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ProfileViewModel extends ChangeNotifier {
  User? user;
  String? errorMessage;
  bool isLoading = false;
  final String token;
  final NotificationService notificationService;

  ProfileViewModel(this.token) : notificationService = NotificationService();

  Future<void> fetchUserData() async {
    final apiService = ApiService(token, notificationService);
    
    try {
      user = await apiService.getUser();
      if (user == null || user!.username == null || user!.email == null) {
        errorMessage = 'User data is incomplete';
      }
    } catch (e) {
      errorMessage = 'Error fetching user data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateUsername(String value) {
    if (user != null) {
      user!.username = value;
      notifyListeners();
    }
  }

  void updateEmail(String value) {
    if (user != null) {
      user!.email = value;
      notifyListeners();
    }
  }

  void updateWeight(String value) {
    if (user != null) {
      user!.weight = double.tryParse(value) ?? user!.weight;
      notifyListeners();
    }
  }

  void updateHeight(String value) {
    if (user != null) {
      user!.height = double.tryParse(value) ?? user!.height;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile() async {
    final apiService = ApiService(token, notificationService);
    
    try {
      await apiService.updateUserProfile(user!);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error updating user profile: $e';
    }

    notifyListeners();
  }
}
