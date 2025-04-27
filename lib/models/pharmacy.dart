class Pharmacy {
  final String name;
  final String address;
  final String phone;

  Pharmacy({required this.name, required this.address, required this.phone});

  // Factory method to create a Pharmacy from a map (the API response)
  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
    );
  }
}
