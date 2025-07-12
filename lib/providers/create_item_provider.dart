import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/services/api_services.dart';

class CreateItemProvider with ChangeNotifier {
  final ApiService apiService;

  CreateItemProvider(this.apiService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> createItem({
    required String token,
    required Map<String, String?> data,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.createItem(
        token: token,
        data: data,
        imageFile: imageFile,
      );

      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Gagal menyimpan item';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
