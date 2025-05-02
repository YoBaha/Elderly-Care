import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FactsScreen extends StatefulWidget {
  const FactsScreen({Key? key}) : super(key: key);

  @override
  _FactsScreenState createState() => _FactsScreenState();
}

class _FactsScreenState extends State<FactsScreen> {
  String? fact;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFact();
  }

  Future<void> _fetchFact() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    const apiUrl = 'https://api.api-ninjas.com/v1/facts'; // Corrected URL

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      print('Facts API Response Status: ${response.statusCode}');
      print('Facts API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is List && data.isNotEmpty) {
            fact = data[0]['fact'] ?? 'No fact available';
          } else {
            fact = 'No fact available';
            errorMessage =
                'Unexpected response format: List is empty or not a list';
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch fact: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Facts API Error: $e');
      setState(() {
        errorMessage = 'Error fetching fact: $e';
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
          'Facts',
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
                'Did You Know?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
                          : Text(
                              fact ?? 'No fact available',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
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
                      fact = null;
                      errorMessage = null;
                    });
                    _fetchFact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Another Fact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
