import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({Key? key}) : super(key: key);

  @override
  _HoroscopeScreenState createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  String? horoscope;
  String? date;
  String? zodiac;
  bool isLoading = true;
  String? errorMessage;
  String selectedSign = 'aries'; // Default zodiac sign

  final List<String> zodiacSigns = [
    'aries',
    'taurus',
    'gemini',
    'cancer',
    'leo',
    'virgo',
    'libra',
    'scorpio',
    'sagittarius',
    'capricorn',
    'aquarius',
    'pisces'
  ];

  @override
  void initState() {
    super.initState();
    _fetchHoroscope();
  }

  Future<void> _fetchHoroscope() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    final apiUrl =
        'https://api.api-ninjas.com/v1/horoscope?zodiac=$selectedSign'; // Changed 'sign' to 'zodiac'

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      print(
          'Horoscope API Response Status: ${response.statusCode}'); // Debug log
      print('Horoscope API Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          horoscope = data['horoscope'] ?? 'No horoscope available';
          date = data['date'] ?? 'N/A';
          zodiac = data['zodiac'] ?? selectedSign;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch horoscope: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Horoscope API Error: $e'); // Debug log
      setState(() {
        errorMessage = 'Error fetching horoscope: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color.fromARGB(255, 20, 240, 189);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text(
          'Horoscope',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Daily Horoscope',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedSign,
                items: zodiacSigns.map((sign) {
                  return DropdownMenuItem(
                    value: sign,
                    child: Text(sign.capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSign = value;
                      isLoading = true;
                      horoscope = null;
                      date = null;
                      zodiac = null;
                      errorMessage = null;
                    });
                    _fetchHoroscope();
                  }
                },
                isExpanded: true,
                hint: const Text('Select Zodiac Sign'),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${date ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Zodiac: ${zodiac?.capitalize() ?? selectedSign.capitalize()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  horoscope ?? 'No horoscope available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
