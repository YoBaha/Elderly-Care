import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late Future<Map<String, dynamic>> _sudokuFuture;
  bool _showSolution = false;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService('', null);
    _sudokuFuture = apiService.fetchSudokuPuzzle(difficulty: 'easy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Game'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showSolution ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showSolution = !_showSolution;
              });
            },
            tooltip: _showSolution ? 'Hide Solution' : 'Show Solution',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _sudokuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final sudokuData = snapshot.data!;
            // Safely cast the puzzle and solution
            final puzzleRaw = sudokuData['puzzle'] as List<dynamic>;
            final solutionRaw = sudokuData['solution'] as List<dynamic>;

            // Convert to List<List<int?>> for puzzle (allowing nulls)
            final puzzle = puzzleRaw
                .map((row) =>
                    (row as List<dynamic>).map((cell) => cell as int?).toList())
                .toList();

            // Convert to List<List<int>> for solution (no nulls)
            final solution = solutionRaw
                .map((row) =>
                    (row as List<dynamic>).map((cell) => cell as int).toList())
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSudokuGrid(_showSolution ? solution : puzzle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sudokuFuture = ApiService('', null)
                            .fetchSudokuPuzzle(difficulty: 'easy');
                        _showSolution = false;
                      });
                    },
                    child: const Text('Generate New Puzzle'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No puzzle found'));
          }
        },
      ),
    );
  }

  Widget _buildSudokuGrid(List<List<dynamic>> grid) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: List.generate(9, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (col) {
              final value = grid[row][col];
              final isInitial = !_showSolution && value != null && value != 0;
              return Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: (row ~/ 3 + col ~/ 3) % 2 == 0
                      ? Colors.white
                      : Colors.grey[200],
                ),
                child: Text(
                  value == null || value == 0 ? '' : value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                    color: isInitial ? Colors.black : Colors.blue,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
