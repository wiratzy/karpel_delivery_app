import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/customer_restaurant_detail_model.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';

class CustomerRestaurantDetailProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService _storageService = StorageService();

  CustomerRestaurantDetailProvider({required this.apiService});

  CustomerRestaurantDetail? _restaurantDetail;
  CustomerRestaurantDetail? get restaurantDetail => _restaurantDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _search = '';
  String get search => _search;

  String? _error; 
  String? get error => _error; 


  void setSearch(String query) {
    _search = query;
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(int restaurantId) async {
    _isLoading = true;
    _error = null; 

    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final detail = await apiService.fetchCustomerRestaurantDetail(token!, restaurantId);
      _restaurantDetail = detail;
    } catch (e) {
     _error = e.toString(); 
      print('❌ Error fetching detail: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Item> get filteredItems {
    if (_restaurantDetail == null) return [];

    return _restaurantDetail!.items
        .where((item) => item.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  List<String> get categories {
  if (_restaurantDetail == null) return [];
  return _restaurantDetail!.items
      .map((item) => item.categoryName ?? 'Lainnya') // Ganti dari item.type
      .toSet()
      .toList();
}


  List<Item> itemsByCategory(String category) {
  return filteredItems
      .where((item) => (item.categoryName ?? 'Lainnya') == category) // Ganti juga dari type
      .toList();
}

}
