import 'package:flutter/material.dart';
import 'screens/cart_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'services/notification_service.dart'; // Import NotificationService
import 'screens/bottom_tab_bar.dart'; // Import BottomTabBar

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService = NotificationService(); // Create an instance of NotificationService

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elderly Care App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Set initial route to login
      routes: {
        '/': (context) => LoginScreen(), // Redirect to login screen
        '/home': (context) => BottomTabBar(token: 'token', notificationService: notificationService), // Pass token and notificationService to BottomTabBar
        '/cart': (context) => CartScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
