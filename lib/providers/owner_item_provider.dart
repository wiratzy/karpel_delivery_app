import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import '../services/api_services.dart';
class OwnerItemProvider with ChangeNotifier {
  final ApiService apiService;

  OwnerItemProvider(this.apiService);

  List<Item> _items = [];
  List<Item> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchItems(String token, {int? categoryId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await apiService.getOwnerItems(token, categoryId: categoryId);
    } catch (e) {
      print('❌ Error fetch items: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
