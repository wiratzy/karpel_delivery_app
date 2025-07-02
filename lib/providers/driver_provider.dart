// providers/driver_provider.dart
import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/api_services.dart';

class DriverProvider with ChangeNotifier {
  final ApiService apiService;
  List<Driver> _drivers = [];
  bool _isLoading = false;

  DriverProvider(this.apiService);

  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;

  Future<void> fetchDrivers(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _drivers = (await apiService.getAvailableDrivers(token)).cast<Driver>();
    } catch (e) {
      _drivers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> assignDriver(String token, int orderId, dynamic driverId) async {
    int parsedDriverId = driverId is String ? int.parse(driverId) : driverId;
    await apiService.assignDriverToOrder(
      orderId: orderId,
      driverId: parsedDriverId,
      token: token,
    );
  }

}
