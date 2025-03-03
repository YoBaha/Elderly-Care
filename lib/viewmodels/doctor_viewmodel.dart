import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class DoctorViewModel extends ChangeNotifier {
  final ApiService apiService;
  String token = ''; // Initialize token to avoid null reference

  DoctorViewModel({required this.apiService, required this.token});

  List<Doctor> _doctors = [];
  String _errorMessage = '';
  bool _isLoading = false;

  List<Doctor> get doctors => _doctors;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<List<Doctor>> fetchDoctors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.getDoctors(); // Use the instance method
      print('Raw response data: $response');
      _doctors =
          response; // Directly assign the List<Doctor> returned from the API
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching doctors: $e';
      print(_errorMessage);
      return []; // Return an empty list in case of error
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _doctors; // Return the list of doctors
  }

  Future<List<Doctor>> fetchDoctorsBySpecialization(
      String specialization) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await apiService.getDoctorsBySpecialization(specialization);
      print('Raw response data: $response');
      _doctors =
          response; // Directly assign the List<Doctor> returned from the API
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching doctors by specialization: $e';
      print(_errorMessage);
      return []; // Return an empty list in case of error
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _doctors; // Return the list of doctors
  }

  void updateToken(String newToken) {
    token = newToken;
    notifyListeners();
  }
}
