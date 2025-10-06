import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/order_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';

class CustomerOrderProvider extends ChangeNotifier {
  final ApiService _apiService;
  CustomerOrderProvider(this._apiService);

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyOrders(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _apiService.getMyOrders(token);
      _orders = responseData.map((e) => Order.fromJson(e)).toList();
      print("🛒 Orders loaded: ${_orders.length}"); // tambahin debug
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Di dalam class CustomerOrderProvider

  Future<Order> fetchOrderById(String token, int orderId) async {
    try {
      // 1. Ambil data dari API
      final data = await _apiService.getCustomerOrderById(token, orderId);

      // 2. Cetak data mentah untuk memastikan isinya benar (opsional tapi bagus untuk debug)
      print("✅ Raw JSON data received for orderId $orderId: $data");

      // 3. Lakukan parsing. Jika error terjadi, akan ditangkap oleh 'catch'.
      return Order.fromJson(data);
    } catch (e, stackTrace) {
      // Tangkap error (e) dan stackTrace-nya

      // 4. Cetak error asli dan di mana terjadinya (stackTrace)
      print(
          "❌ Terjadi error saat parsing Order.fromJson untuk orderId $orderId.");
      print("Error Asli: $e");
      print("Stack Trace: $stackTrace");

      // 5. Lempar kembali error ASLI agar bisa ditangani di UI dengan benar
      // Ini akan memberikan pesan error yang jauh lebih detail.
      rethrow;
    }
  }

  Future<void> updateOrderStatus(
    String token,
    int orderId,
    String status, {
    int? restaurantRating,
    int? itemRating,
    String? reviewText,
  }) async {
    await _apiService.updateCustomerOrderStatus(
      token,
      orderId,
      status,
      restaurantRating: restaurantRating,
      itemRating: itemRating,
      reviewText: reviewText,
    );
  }
}
