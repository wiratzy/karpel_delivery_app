// lib/providers/home_provider.dart
import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/home_model.dart';

import 'package:karpel_food_delivery/services/api_services.dart';

class HomeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ItemCategory> _categories = [];
  List<Restaurant> _popularRestaurants = [];
  List<Item> _recentItems = [];
  bool _isLoading = false;
  String? _error;

  List<ItemCategory> get categories => _categories;
  List<Restaurant> get popularRestaurants => _popularRestaurants;
  List<Item> get recentItems => _recentItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHomeData(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getHomeData(token);
      print('Home data response: $response'); // Debug log

      if (response['success'] == true) {
        // Parsing categories
        final categoriesList = response['data']['categories'] as List?;
        _categories = categoriesList != null
            ? categoriesList
                .where((item) => item != null) // Filter elemen null
                .map((item) {
                print('Parsing category: $item'); // Debug log
                return ItemCategory.fromJson(item as Map<String, dynamic>);
              }).toList()
            : [];

        // Parsing popular restaurants
        final popularList = response['data']['popular'] as List?;
        _popularRestaurants = popularList != null
            ? popularList.where((item) => item != null).map((item) {
                print('Parsing popular restaurant: $item'); // Debug log
                return Restaurant.fromJson(item as Map<String, dynamic>);
              }).toList()
            : [];

        // Parsing recent items
        final recentItemsList = response['data']['recent_items'] as List?;
        _recentItems = recentItemsList != null
            ? recentItemsList.where((item) => item != null).map((item) {
                print('Parsing recent item: $item'); // Debug log
                return Item.fromJson(item as Map<String, dynamic>);
              }).toList()
            : [];
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk pengujian
  void setCategoriesForTesting(List<ItemCategory> categories) {
    _categories = categories;
    notifyListeners();
  }

  void setPopularRestaurantsForTesting(List<Restaurant> restaurants) {
    _popularRestaurants = restaurants;
    notifyListeners();
  }

  void setRecentItemsForTesting(List<Item> items) {
    _recentItems = items;
    notifyListeners();
  }
}
