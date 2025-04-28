import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/exercise.dart'; // Add this import

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Future<List<Exercise>> _exercisesFuture; // Updated type
  String? selectedMuscle = 'biceps';
  String? selectedDifficulty;
  String? selectedType;

  final List<String> muscleGroups = [
    'abdominals',
    'abductors',
    'adductors',
    'biceps',
    'calves',
    'chest',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'lower_back',
    'middle_back',
    'neck',
    'quadriceps',
    'traps',
    'triceps',
  ];

  final List<String> difficulties = ['beginner', 'intermediate', 'expert'];

  final List<String> types = [
    'cardio',
    'olympic_weightlifting',
    'plyometrics',
    'powerlifting',
    'strength',
    'stretching',
    'strongman',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  void _fetchExercises() {
    final apiService = ApiService('', null);
    _exercisesFuture = apiService.fetchExercises(
      muscle: selectedMuscle,
      difficulty: selectedDifficulty,
      type: selectedType,
    );
  }

  void _onFilterChanged() {
    setState(() {
      _fetchExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.teal.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterDropdown(
                  hint: 'Muscle',
                  value: selectedMuscle,
                  items: muscleGroups,
                  onChanged: (value) {
                    setState(() {
                      selectedMuscle = value;
                      _onFilterChanged();
                    });
                  },
                ),
                _buildFilterDropdown(
                  hint: 'Difficulty',
                  value: selectedDifficulty,
                  items: difficulties,
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value;
                      _onFilterChanged();
                    });
                  },
                ),
                _buildFilterDropdown(
                  hint: 'Type',
                  value: selectedType,
                  items: types,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      _onFilterChanged();
                    });
                  },
                ),
              ],
            ),
          ),
          // Exercise List
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final exercises = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ExerciseCard(exercise: exercise);
                    },
                  );
                } else {
                  return const Center(child: Text('No exercises found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: value,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All'),
        ),
        ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item.capitalize()),
            )),
      ],
      onChanged: onChanged,
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.teal, fontSize: 14),
      dropdownColor: Colors.white,
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Custom Exercise Card Widget
class ExerciseCard extends StatelessWidget {
  final Exercise exercise; // Updated type

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showExerciseDetails(context, exercise);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Placeholder for exercise thumbnail/icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Exercise Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Muscle: ${exercise.muscle.capitalize()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Difficulty: ${exercise.difficulty.capitalize()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Type: ${exercise.type.capitalize()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.teal,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Muscle: ${exercise.muscle.capitalize()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${exercise.difficulty.capitalize()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${exercise.type.capitalize()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Equipment: ${exercise.equipment.capitalize()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.instructions,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }
}
