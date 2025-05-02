import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JokesScreen extends StatefulWidget {
  const JokesScreen({Key? key}) : super(key: key);

  @override
  _JokesScreenState createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  String? joke;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchJoke();
  }

  Future<void> _fetchJoke() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    const apiUrl = 'https://api.api-ninjas.com/v1/jokes';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          joke = data.isNotEmpty ? data[0]['joke'] : 'No joke available';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch joke: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching joke: $e';
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
          'Jokes',
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
                'Have a Laugh',
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
                              joke ?? 'No joke available',
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
                      joke = null;
                      errorMessage = null;
                    });
                    _fetchJoke();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Another Joke'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
