enum Role {
  user,
  doctor,
  admin,
}

enum ChronicIllness {
  diabetes,
  hypertension,
  asthma,
}

class User {
  String email;
  String password;
  String username;
  DateTime birthDate;
  List<ChronicIllness> chronicIllnesses;
  double weight;
  double height;
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      username: json['username'] ?? '',
      birthDate: DateTime.tryParse(json['birthDate']) ?? DateTime.now(),
      chronicIllnesses: (json['chronicIllnesses'] as List?)
              ?.map((illness) => ChronicIllness.values
                  .firstWhere((e) => e.toString().split('.').last == illness))
              .toList() ??
          [],
      weight: json['weight'] ?? 0.0,
      height: json['height'] ?? 0.0,
      profilePic: json['profilePic'],
      role: Role.values.firstWhere(
          (e) => e.toString().split('.').last == json['role'],
          orElse: () => Role.user),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'birthDate': birthDate.toIso8601String(),
      'chronicIllnesses': chronicIllnesses
          .map((illness) => illness.toString().split('.').last)
          .toList(),
      'weight': weight,
      'height': height,
      'profilePic': profilePic,
      'role': role.toString().split('.').last,
    };
  }
}
