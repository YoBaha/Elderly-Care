class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String specialization;
  final double rating;
  final double distance;
  final String profilePicture;
  final String email; // Make email optional
  final bool availability;
  final List<double> location;
  final List<Review> reviews;

  static const String defaultEmail = 'no-email@example.com';

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialization,
    required this.rating,
    required this.distance,
    required this.profilePicture,
    required this.email,
    required this.availability,
    required this.location,
    required this.reviews,
  });

  String get profilePictureUrl {
    if (profilePicture.startsWith('http')) {
      return profilePicture;
    } else if (profilePicture.startsWith('C:/')) {
      // Convert local Windows path to file URI
      String path = profilePicture.replaceFirst('file://', '');
      return 'file://' + Uri.encodeFull(path);
    }
    return ''; // Return empty string if no valid path
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    List<String> missingFields = [];

    if (json['_id'] == null) missingFields.add('_id');
    if (json['firstName'] == null) missingFields.add('firstName');
    if (json['lastName'] == null) missingFields.add('lastName');
    if (json['specialization'] == null) missingFields.add('specialization');

    if (missingFields.isNotEmpty) {
      print('Missing required fields: ${missingFields.join(', ')}');
      print('Doctor data: $json');
      return Doctor(
        id: json['_id'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        specialization: json['specialization'] ?? '',
        rating: json['rating']?.toDouble() ?? 0.0,
        distance: json['distance']?.toDouble() ?? 0.0,
        profilePicture: json['profilePicture']?.toString() ?? '',
        email: json['email'] ?? defaultEmail,
        availability: json['availability'] ?? true,
        location: List<double>.from(
          (json['location']['coordinates'] as List).map((coord) {
            if (coord is double) return coord;
            if (coord is int) return coord.toDouble();
            if (coord is String) return double.tryParse(coord) ?? 0.0;
            return 0.0;
          }).toList(),
        ),
        reviews: List<Review>.from(
            json['reviews']?.map((x) => Review.fromJson(x)) ?? []),
      );
    }

    return Doctor(
      id: json['_id']!,
      firstName: json['firstName']!,
      lastName: json['lastName']!,
      specialization: json['specialization']!,
      rating: json['rating']?.toDouble() ?? 0.0,
      distance: json['distance']?.toDouble() ?? 0.0,
      profilePicture: json['profilePicture']?.toString() ?? '',
      email: json['email'] ?? defaultEmail,
      availability: json['availability'] ?? true,
      location: List<double>.from(
        (json['location']['coordinates'] as List).map((coord) {
          if (coord is double) return coord;
          if (coord is int) return coord.toDouble();
          if (coord is String) return double.tryParse(coord) ?? 0.0;
          return 0.0;
        }).toList(),
      ),
      reviews: List<Review>.from(
          json['reviews']?.map((x) => Review.fromJson(x)) ?? []),
    );
  }
}

class Review {
  final String userId;
  final double rating;
  final String comment;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'],
      rating: json['rating']?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
    );
  }
}
