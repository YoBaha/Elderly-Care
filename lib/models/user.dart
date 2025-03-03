enum Role {
  user,
  doctor,
  admin,
}

enum ChronicIllness {
  diabetes,
  hypertension,
  asthma,
  // Add other chronic illnesses here as needed
}

class User {
  String email; // Changed from final to allow updates
  String password; // Changed from final to allow updates
  String username; // Changed from final to allow updates
  DateTime birthDate;
  List<ChronicIllness> chronicIllnesses;
  double weight; // Changed from final to allow updates
  double height; // Changed from final to allow updates
  final String? profilePic;
  final Role role;

  User({
    required this.email,
    required this.password,
    required this.username,
    required this.birthDate,
    required this.chronicIllnesses,
    required this.weight,
    required this.height,
    this.profilePic,
    required this.role,
  });

  // Method to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '', // Provide default value
      password: json['password'] ?? '', // Provide default value
      username: json['username'] ?? '', // Provide default value
      birthDate: DateTime.tryParse(json['birthDate']) ?? DateTime.now(), // Handle null and provide default
      chronicIllnesses: (json['chronicIllnesses'] as List?)?.map((illness) => ChronicIllness.values.firstWhere((e) => e.toString().split('.').last == illness)).toList() ?? [], // Handle null
      weight: json['weight'] ?? 0.0, // Provide default value
      height: json['height'] ?? 0.0, // Provide default value
      profilePic: json['profilePic'], // Nullable
      role: Role.values.firstWhere((e) => e.toString().split('.').last == json['role'], orElse: () => Role.user), // Provide default role
    );
  }

  // Add the toJson method to serialize the User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'birthDate': birthDate.toIso8601String(), // Convert DateTime to String
      'chronicIllnesses': chronicIllnesses.map((illness) => illness.toString().split('.').last).toList(), // Convert enum list to strings
      'weight': weight,
      'height': height,
      'profilePic': profilePic,
      'role': role.toString().split('.').last, // Convert enum to string
    };
  }
}
