import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/customer_restaurant_detail_model.dart';
import 'package:karpel_food_delivery/models/customer_restaurant_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';

class CustomerRestaurantProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService _storageService = StorageService();

  CustomerRestaurantProvider({required this.apiService});

  List<CustomerRestaurant> _restaurants = [];
  List<CustomerRestaurant> get restaurants => _restaurants;
  CustomerRestaurantDetail? _selectedRestaurant;
  CustomerRestaurantDetail? get selectedRestaurant => _selectedRestaurant;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _search = '';
  int? _rate;

  void search(String value) {
    _search = value;
    fetchRestaurants(search: _search, rate: _rate);
  }

  void filterByRating(int rate) {
    _rate = rate;
    fetchRestaurants(search: _search, rate: _rate);
  }

  Future<void> fetchRestaurants({String? search, int? rate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final data = await apiService.fetchCustomerRestaurants(
        token!,
        search: search,
        rate: rate,
      );
      _restaurants = data;
    } catch (e) {
      print('❌ Error fetching restaurants: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRestaurantById(int id) async {
  _isLoading = true;
  notifyListeners();

  try {
    final token = await _storageService.getToken();
    final data = await apiService.fetchCustomerRestaurantDetail(token!, id);
    _selectedRestaurant = data;
  } catch (e) {
    print('❌ fetchRestaurantById error: $e');
  }

  _isLoading = false;
  notifyListeners();
}
}
