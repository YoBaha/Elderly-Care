import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sudoku_screen.dart';

import 'package:flutter/material.dart';
import 'horoscope_screen.dart';
import 'facts_screen.dart';
import 'trivia_screen.dart';
import 'hobbies_screen.dart';
import 'riddles_screen.dart';
import 'jokes_screen.dart';

class GamesScreen extends StatelessWidget {
  final String token;

  const GamesScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color.fromARGB(255, 20, 240, 189);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text(
          'Games & Activities',
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
                'Explore Fun Activities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildGameCard(
                context,
                title: 'Sudoku',
                icon: Icons.grid_3x3,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SudokuScreen(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                context,
                title: 'Horoscope',
                icon: Icons.star,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HoroscopeScreen(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                context,
                title: 'Facts',
                icon: Icons.lightbulb,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FactsScreen(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                context,
                title: 'Trivia',
                icon: Icons.quiz,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TriviaScreen(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                context,
                title: 'Hobbies',
                icon: Icons.brush,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HobbiesScreen(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                context,
                title: 'Riddles',
                icon: Icons.question_mark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiddlesScreen(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                context,
                title: 'Jokes',
                icon: Icons.emoji_emotions,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JokesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 30),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
