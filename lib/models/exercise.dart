class Exercise {
  final String name;
  final String muscle;
  final String difficulty;
  final String type;
  final String equipment;
  final String instructions;

  Exercise({
    required this.name,
    required this.muscle,
    required this.difficulty,
    required this.type,
    required this.equipment,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name']?.toString() ?? 'Unnamed Exercise',
      muscle: json['muscle']?.toString() ?? 'N/A',
      difficulty: json['difficulty']?.toString() ?? 'N/A',
      type: json['type']?.toString() ?? 'N/A',
      equipment: json['equipment']?.toString() ?? 'None',
      instructions:
          json['instructions']?.toString() ?? 'No instructions available.',
    );
  }
}
