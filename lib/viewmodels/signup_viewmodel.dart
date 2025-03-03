import '../services/api_service.dart';
import '../models/user.dart'; // Import the User model

class SignupViewModel {
  String email = '';
  String password = '';
  String username = '';
  double weight = 0.0; // Add weight field
  double height = 0.0; // Add height field
  DateTime? birthDate; // Change to nullable
  String? profilePic; // Mark as nullable
  List<String> chronicIllnesses = []; // Add chronicIllnesses field
  String token = ''; // Add a token field

  final ApiService apiService;

  SignupViewModel(this.apiService); // Update constructor to accept ApiService

  Future<bool> signup() async {
    try {
      // Create a User object
      User user = User(
        email: email,
        password: password,
        username: username,
        birthDate: birthDate ?? DateTime.now(), // Provide a default value if null
        chronicIllnesses: chronicIllnesses.map((illness) => ChronicIllness.values.firstWhere((e) => e.toString().split('.').last == illness)).toList(), // Convert to List<ChronicIllness>
        weight: weight,
        height: height,
        profilePic: profilePic ?? '', // Use the initialized profilePic
        role: Role.user, // Set a default role or modify as needed
      );

      // Call the signup method and get the token
      token = await apiService.signup(user); // Pass the User object
      print('Signup successful'); // Debugging statement
      return true; // Return true on successful signup
    } catch (e) {
      print('Signup error: $e');
      return false; // Return false on error
    }
  }
}
