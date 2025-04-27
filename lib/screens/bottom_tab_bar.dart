import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'marketplace_screen.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class BottomTabBar extends StatefulWidget {
  final String token;
  final NotificationService notificationService;

  BottomTabBar({required this.token, required this.notificationService});

  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        token: widget.token,
        notificationService: widget.notificationService,
      ),
      ProfileScreen(token: widget.token),
      MarketplaceScreen(
        token: widget.token,
        notificationService: widget.notificationService,
      ),
      SettingsScreen(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(),
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.store), label: 'Marketplace'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
