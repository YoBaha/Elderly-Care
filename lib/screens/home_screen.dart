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
import 'sign_language_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  final String token;
  final NotificationService notificationService;

  HomeScreen({required this.token, required this.notificationService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  int _selectedIndex = 0;
  String? motivationalQuote;
  late NotificationService _notificationService;

  late final List<Widget> _screens = [
    HomeContent(
        token: widget.token, notificationService: widget.notificationService),
    HomeBot(),
    ProfileScreen(token: widget.token),
  ];

  @override
  void initState() {
    super.initState();
    _notificationService = widget.notificationService;
    _fetchInitialQuote();
    _setupNotifications();
  }

  Future<void> _fetchInitialQuote() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final quote = await apiService.fetchMotivationalQuote();
      setState(() {
        motivationalQuote = quote;
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
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_mosaic), label: 'HealthBot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final String token;
  final NotificationService notificationService;

  const HomeContent({
    Key? key,
    required this.token,
    required this.notificationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildCategoryRow(context),
            const SizedBox(height: 16),
            _buildMotivationalBanner(context),
            const SizedBox(height: 16),
            _buildDoctorSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Find your desire\nhealth solution",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emergency, color: Colors.red),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyButtonScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Notification logic
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(LucideIcons.messageCircle),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search doctor, drugs, articles...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _categoryIcon(Icons.local_hospital, "Doctor",
            onTap: () => Navigator.pushNamed(context, '/doctors')),
        _categoryIcon(Icons.shopping_bag, "Marketplace", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarketplaceScreen(
                token: token,
                notificationService: notificationService,
              ),
            ),
          );
        }),
        _categoryIcon(Icons.local_pharmacy, "Pharmacy", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PharmacyScreen()),
          );
        }),
        _categoryIcon(Icons.medical_services, "Exercises", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExercisesScreen()),
          );
        }),
        _categoryIcon(Icons.grid_3x3, "Games", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GamesScreen(token: token)),
          );
        }),
        _categoryIcon(Icons.gesture, "Sign Language", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignLanguageScreen()),
          );
        }), // Add this new category
      ],
    );
  }

  Widget _buildMotivationalBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your health is our Priority",
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Learn more"),
                ),
              ],
            ),
          ),
          Image.asset("assets/doctor.png", width: 80),
        ],
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Your Doctors"),
        const SizedBox(height: 8),
        Container(
          height: 180,
          child: _doctorList(context),
        ),
      ],
    );
  }

  Widget _categoryIcon(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.teal),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "See all",
          style: TextStyle(fontSize: 14, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _doctorList(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _doctorCard(
              context, "Dr. Marcus Horiz", "Cardiologist", "4.7", "800m away"),
          _doctorCard(
              context, "Dr. Maria Elena", "Psychologist", "4.8", "1.5km away"),
          _doctorCard(
              context, "Dr. Stevi Jes", "Orthopedist", "4.6", "2km away"),
        ],
      ),
    );
  }

  Widget _doctorCard(BuildContext context, String name, String specialty,
      String rating, String distance) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailScreen(doctor: doctor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, top: 8),
        padding: const EdgeInsets.all(12),
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 30,
              child: Icon(Icons.person, size: 40, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text(
              '${doctor.firstName} ${doctor.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(specialty,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                Text(rating, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text(distance,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
