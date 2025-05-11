import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../pages/home_bot.dart';
import 'doctor_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../pages/chatscreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'marketplace_screen.dart';
import '../pages/pharmacy_screen.dart';
import '../pages/emergency_button_screen.dart';
import 'exercises_screen.dart';
import 'sudoku_screen.dart';
import 'games_screen.dart';
import 'sign_language_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final NotificationService notificationService;

  const HomeScreen({required this.token, required this.notificationService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  int _selectedIndex = 0;
  String? motivationalQuote;
  late NotificationService _notificationService;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _notificationService = widget.notificationService;
    _fetchInitialQuote();
    _setupNotifications();
    _screens = [
      HomeContent(
        token: widget.token,
        notificationService: widget.notificationService,
        motivationalQuote: motivationalQuote, // Pass motivationalQuote
      ),
      HomeBot(),
      ProfileScreen(token: widget.token),
    ];
  }

  Future<void> _fetchInitialQuote() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final quote = await apiService.fetchMotivationalQuote();
      setState(() {
        motivationalQuote = quote;
        // Update _screens to reflect new quote
        _screens[0] = HomeContent(
          token: widget.token,
          notificationService: widget.notificationService,
          motivationalQuote: motivationalQuote,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch motivational quote: $e')),
      );
    }
  }

  Future<void> _setupNotifications() async {
    await _notificationService.init();
    await _notificationService.showQuoteNotification();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Sidebar Navigation
              Container(
                width: 250,
                color: primaryColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Health App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _sidebarItem(
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: _selectedIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    _sidebarItem(
                      icon: Icons.auto_awesome_mosaic,
                      label: 'HealthBot',
                      isSelected: _selectedIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                    _sidebarItem(
                      icon: Icons.person,
                      label: 'Profile',
                      isSelected: _selectedIndex == 2,
                      onTap: () => _onItemTapped(2),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '© 2025 Health App',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final String token;
  final NotificationService notificationService;
  final String? motivationalQuote; // Add motivationalQuote parameter

  const HomeContent({
    Key? key,
    required this.token,
    required this.notificationService,
    required this.motivationalQuote, // Make required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Navigation Bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome to Your Health Hub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emergency,
                          color: Colors.red, size: 28),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmergencyButtonScreen()),
                      ),
                      tooltip: 'Emergency',
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications,
                          color: Colors.grey, size: 28),
                      onPressed: () {
                        // Notification logic
                      },
                      tooltip: 'Notifications',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.messageCircle,
                          color: primaryColor, size: 28),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      ),
                      tooltip: 'Chat',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search Section
          Container(
            padding: const EdgeInsets.all(40.0),
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: Container(
                width: 600,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search doctor, drugs, articles...',
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Categories Section
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Health Services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _categoryCard(
                      icon: Icons.local_hospital,
                      title: 'Doctor',
                      onTap: () => Navigator.pushNamed(context, '/doctors'),
                    ),
                    _categoryCard(
                      icon: Icons.shopping_bag,
                      title: 'Marketplace',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarketplaceScreen(
                            token: token,
                            notificationService: notificationService,
                          ),
                        ),
                      ),
                    ),
                    _categoryCard(
                      icon: Icons.local_pharmacy,
                      title: 'Pharmacy',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PharmacyScreen()),
                      ),
                    ),
                    _categoryCard(
                      icon: Icons.medical_services,
                      title: 'Exercises',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExercisesScreen()),
                      ),
                    ),
                    _categoryCard(
                      icon: Icons.grid_3x3,
                      title: 'Games',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GamesScreen(token: token)),
                      ),
                    ),
                    _categoryCard(
                      icon: Icons.gesture,
                      title: 'Sign Language',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignLanguageScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Motivational Banner
          Container(
            padding: const EdgeInsets.all(40.0),
            color: primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Health is Our Priority',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          motivationalQuote ?? 'Stay healthy, live better!',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Learn More',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    'assets/doctor.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          // Doctors Section
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Doctors',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/doctors'),
                      child: Text(
                        'See All',
                        style: TextStyle(color: primaryColor, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                  children: [
                    _doctorCard(
                      context,
                      'Dr. Marcus Horiz',
                      'Cardiologist',
                      '4.7',
                      '800m away',
                    ),
                    _doctorCard(
                      context,
                      'Dr. Maria Elena',
                      'Psychologist',
                      '4.8',
                      '1.5km away',
                    ),
                    _doctorCard(
                      context,
                      'Dr. Stevi Jes',
                      'Orthopedist',
                      '4.6',
                      '2km away',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF199A8E);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: primaryColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _doctorCard(
    BuildContext context,
    String name,
    String specialty,
    String rating,
    String distance,
  ) {
    final doctor = Doctor(
      id: '1',
      firstName: name.split(' ')[0],
      lastName: name.split(' ')[1],
      specialization: specialty,
      rating: double.parse(rating),
      distance: double.parse(distance.replaceAll(RegExp(r'[^0-9.]'), '')),
      profilePicture: '',
      email: 'doctor@example.com',
      availability: true,
      location: [0.0, 0.0],
      reviews: [],
    );
    const primaryColor = Color(0xFF199A8E);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctor),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 40,
                  child: Icon(Icons.person, size: 50, color: primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  '${doctor.firstName} ${doctor.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 14)),
                    const Spacer(),
                    Text(
                      distance,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
