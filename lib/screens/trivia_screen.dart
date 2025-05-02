import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({Key? key}) : super(key: key);

  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  String? question;
  String? answer;
  bool showAnswer = false;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrivia();
  }

  Future<void> _fetchTrivia() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    const apiUrl = 'https://api.api-ninjas.com/v1/trivia';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          question =
              data.isNotEmpty ? data[0]['question'] : 'No question available';
          answer = data.isNotEmpty ? data[0]['answer'] : 'No answer available';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch trivia: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching trivia: $e';
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
          'Trivia',
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
                'Test Your Knowledge',
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
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question ?? 'No question available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (showAnswer)
                                  Text(
                                    'Answer: ${answer ?? 'No answer available'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAnswer = !showAnswer;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(showAnswer ? 'Hide Answer' : 'Show Answer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        question = null;
                        answer = null;
                        errorMessage = null;
                        showAnswer = false;
                      });
                      _fetchTrivia();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Next Question'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
