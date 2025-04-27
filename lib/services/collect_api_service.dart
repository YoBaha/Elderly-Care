import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/pharmacy.dart';

class CollectApiService {
  final String apiKey = 'apikey 73JumpIelqSerx1pWyPP8b:4GxTfMdvyy2Rn6rujALdwr';

  // Method to get pharmacy data
  Future<List<Pharmacy>> getPharmacies(String city) async {
    final String url =
        'https://api.collectapi.com/health/dutyPharmacy?ilce=%C3%87ankaya&il=Ankara';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'apikey $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        List<dynamic> pharmacyData = data['result'];
        return pharmacyData.map((json) => Pharmacy.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pharmacies');
      }
    } else {
      throw Exception('Failed to load pharmacies');
    }
  }
}
