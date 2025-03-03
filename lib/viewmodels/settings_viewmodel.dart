import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = false;

  SettingsViewModel() {
    _loadSettings();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveSettings();
    notifyListeners();
  }

  void toggleNotifications() {
    _isNotificationsEnabled = !_isNotificationsEnabled;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _isNotificationsEnabled = prefs.getBool('notifications') ?? false;
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _isNotificationsEnabled);
  }
}
