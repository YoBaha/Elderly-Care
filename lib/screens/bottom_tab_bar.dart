import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'home_screen.dart';
import '../viewmodels/settings_viewmodel.dart'; // Import SettingsViewModel

import 'profile_screen.dart';
import 'marketplace_screen.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart'; // Import NotificationService

class BottomTabBar extends StatefulWidget {
  final String token; // Add token parameter
  final NotificationService notificationService; // Add NotificationService parameter

  BottomTabBar({required this.token, required this.notificationService}); // Constructor to accept token and notificationService

  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(),
      ProfileScreen(token: widget.token), // Pass the token to ProfileScreen
      MarketplaceScreen(widget.token, widget.notificationService), // Pass the token and notificationService to MarketplaceScreen
      SettingsScreen(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(), // Provide SettingsViewModel
      child: Scaffold(



      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(

      
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    ));
  }
}
