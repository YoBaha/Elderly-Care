import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HobbiesScreen extends StatefulWidget {
  const HobbiesScreen({Key? key}) : super(key: key);

  @override
  _HobbiesScreenState createState() => _HobbiesScreenState();
}

class _HobbiesScreenState extends State<HobbiesScreen> {
  String? hobby;
  String? category;
  String? link;
  bool isLoading = true;
  String? errorMessage;
  String? selectedCategory; // Null for no category filter

  final List<String> categories = [
    'All', // Represents no category filter
    'general',
    'sports_and_outdoors',
    'education',
    'collection',
    'competition',
    'observation'
  ];

  @override
  void initState() {
    super.initState();
    _fetchHobby();
  }

  Future<void> _fetchHobby() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    final apiUrl = selectedCategory == null || selectedCategory == 'All'
        ? 'https://api.api-ninjas.com/v1/hobbies'
        : 'https://api.api-ninjas.com/v1/hobbies?category=$selectedCategory';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      print('Hobbies API Response Status: ${response.statusCode}');
      print('Hobbies API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Single object
        setState(() {
          hobby = data['hobby'] ?? 'No hobby available';
          category = data['category'] ?? 'N/A';
          link = data['link'] ?? null;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch hobby: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Hobbies API Error: $e');
      setState(() {
        errorMessage = 'Error fetching hobby: $e';
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
          'Hobbies',
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
                'Discover a New Hobby',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCategory ?? 'All',
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat == 'All'
                        ? 'All Categories'
                        : cat.replaceAll('_', ' ').capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value == 'All' ? null : value;
                      isLoading = true;
                      hobby = null;
                      category = null;
                      link = null;
                      errorMessage = null;
                    });
                    _fetchHobby();
                  }
                },
                isExpanded: true,
                hint: const Text('Select Category'),
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
                                  hobby ?? 'No hobby available',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Category: ${category ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (link != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Learn more: $link',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      hobby = null;
                      category = null;
                      link = null;
                      errorMessage = null;
                    });
                    _fetchHobby();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Another Hobby'),
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
