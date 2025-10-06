import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/admin_item_category_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';

class AdminItemCategoryProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService _storageService = StorageService();

  AdminItemCategoryProvider({required this.apiService});

  List<AdminItemCategory> _categories = [];
  List<AdminItemCategory> get categories => _categories;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String _token = '';

  Future<void> init() async {
    _token = await _storageService.getToken() ?? '';
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      print('Fetching item categories with token: $_token');
      final data = await apiService.fetchAdminItemCategories(_token);
      _categories = data;
    } catch (e) {
      print('❌ fetchCategories error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(Map<String, String> fields, File? imageFile) async {
    try {
      await apiService.createAdminItemCategory(_token, fields, imageFile);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editCategory(int id, Map<String, String> fields, File? imageFile) async {
    try {
      await apiService.updateAdminItemCategory(_token, id, fields, imageFile);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await apiService.deleteAdminItemCategory(_token, id);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }
}
