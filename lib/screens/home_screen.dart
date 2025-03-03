import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pim/pages/home_bot.dart';
import '../services/notification_service.dart';
import 'profile_screen.dart';
import 'marketplace_screen.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../pages/chatscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your daily motivation",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_outlined),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(LucideIcons.messageCircle),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MotivationalQuote(),
              const SizedBox(height: 16),
              _quickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotivationalQuote extends StatefulWidget {
  @override
  _MotivationalQuoteState createState() => _MotivationalQuoteState();
}

class _MotivationalQuoteState extends State<_MotivationalQuote> {
  String? motivationalQuote;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final quote = await apiService.fetchMotivationalQuote();
      setState(() {
        motivationalQuote = quote;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load quote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: motivationalQuote != null
          ? Text(
              motivationalQuote!,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          : CircularProgressIndicator(),
    );
  }
}

Widget _quickActions() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _actionIcon(Icons.shopping_cart, "Marketplace"),
      _actionIcon(Icons.settings, "Settings"),
      _actionIcon(Icons.person, "Profile"),
    ],
  );
}

Widget _actionIcon(IconData icon, String title) {
  return Column(
    children: [
      Icon(icon, size: 30, color: Colors.blue),
      Text(title, style: TextStyle(fontSize: 12)),
    ],
  );
}
