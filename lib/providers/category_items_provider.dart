// lib/providers/category_items_provider.dart
import 'package:flutter/material.dart';
import 'package:kons2/models/home_model.dart';
import '../services/api_services.dart';

class CategoryItemsProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<ItemCategory> _categories = [];
  List<Item> _items = []; // Variabel baru untuk items

  final ApiService _apiService = ApiService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ItemCategory> get categories => _categories;
  List<Item> get items => _items; // Getter baru untuk items

  // Fungsi untuk mengambil kategori (dipertahankan)
  Future<void> fetchCategories(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categoriesResponse = await _apiService.getAllCategories(token);
      print('Categories Response: $categoriesResponse');
      _categories = categoriesResponse.map((json) => ItemCategory.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      print('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchItemsCategories(String token, int categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching items for categoryId: $categoryId with token: $token');
      final itemsResponse = await _apiService.getItemsByCategory(token, categoryId);
      print('Items Response: $itemsResponse');
      _items = itemsResponse.map((json) => Item.fromJson(json)).toList();
      if (_items.isEmpty) {
        _error = 'No items found for this category';
      }
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      print('Error fetching items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Membersihkan daftar items
  void clearItems() {
    _items = [];
    _error = null;
  }
}