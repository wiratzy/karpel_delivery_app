import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/driver_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart'; // jika simpan token di shared prefs

class OwnerDriverProvider extends ChangeNotifier {
  final ApiService apiService;

  OwnerDriverProvider({required this.apiService});

  List<Driver> _drivers = [];
  List<Driver> _filteredDrivers = [];

  List<Driver> get drivers => _filteredDrivers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final StorageService _storageService = StorageService();

  String _token = '';

  Future<void> init() async {
    _token = await _storageService.getToken() ?? '';
    await fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await apiService.fetchDrivers(_token);
      _drivers = data;
      _filteredDrivers = data;
    } catch (e) {
      print('❌ Error fetchDrivers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDriver(Map<String, dynamic> body) async {
    try {
      await apiService.createDriver(_token, body);
      await fetchDrivers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editDriver(int id, Map<String, dynamic> body) async {
    try {
      await apiService.updateDriver(_token, id, body);
      await fetchDrivers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDriver(int id) async {
    try {
      await apiService.deleteDriver(_token, id);
      await fetchDrivers();
    } catch (e) {
      rethrow;
    }
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      _filteredDrivers = _drivers;
    } else {
      _filteredDrivers = _drivers
          .where((d) => d.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
