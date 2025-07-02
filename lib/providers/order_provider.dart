import 'package:flutter/material.dart';
import 'package:kons2/models/order_model.dart';
import 'package:kons2/models/order_request_model.dart';
import 'package:kons2/models/user_model.dart';
import 'package:kons2/services/api_services.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService;
  OrderProvider(this._apiService);

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ambil semua order untuk restoran owner
  Future<void> fetchRestaurantOrders(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _apiService.getRestoOrders(token);
      _orders = responseData.map((data) => Order.fromJson(data)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat data pesanan: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ambil ulang 1 order by ID
 Future<Order> refreshOrderById(String token, int orderId) async {
  try {
    final data = await _apiService.getOrderById(token, orderId);
    return Order.fromJson(data);
  } catch (e) {
    throw Exception("Gagal mengambil detail order: $e");
  }
}


  // Update status pesanan
  Future<void> updateOrderStatus(String token, int orderId, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(token, orderId, newStatus);
    } catch (e) {
      print('Gagal update status: $e');
    }
  }
  Future<Map<String, dynamic>> checkoutOrder(String token, OrderRequest orderRequest) async {
    try {
      final response = await _apiService.checkout(token, orderRequest.toJson());
      return response;
    } catch (e) {
      final response = await _apiService.checkout(token, orderRequest.toJson());
      print(response); 
      throw Exception("Gagal checkout: $e");
    }
  }

//   Future<List<User>> fetchAvailableDrivers(String token) async {
//   final response = await _apiService.getAvailableDrivers(token); // Buat di ApiService juga
//   return (response['drivers'] as List).map((e) => User.fromJson(e)).toList();
// }




}
