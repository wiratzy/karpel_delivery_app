import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/cart_model.dart';
import '../models/home_model.dart';
import '../services/api_services.dart';

class ItemProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Item? _item;
  bool _isLoading = false;
  String? _error;
  List<CartItem> _cartItems = [];
  Map<String, dynamic>? _pendingCartItem;

  Item? get item => _item;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorMessage => _error;
  int? _updatingItemId;
int? get updatingItemId => _updatingItemId;
  List<CartItem> get cartItems => _cartItems;
  Map<String, dynamic>? get pendingCartItem => _pendingCartItem;
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item.price) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }
  double get total => subtotal + deliveryCost;

  double get deliveryCost {
    if (_cartItems.isNotEmpty && _cartItems.first.item.restaurant != null) {
      double? parsedDeliveryFee = _cartItems.isNotEmpty
          ? _cartItems.first.item.restaurant.deliveryFee
          : null;
      return parsedDeliveryFee ?? 0.0; // Pastikan mengembalikan double
    }
    return 0.0; // Default jika tidak ada data restoran
  }


  Future<void> fetchItemDetails(String token, int itemId) async {
    _isLoading = true;
    _error = null;

    try {
      _item = await _apiService.fetchItemDetails(token, itemId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(
    String token,
    int userId,
    int itemId,
    int quantity,
  ) async {
    _isLoading = true;
    notifyListeners(); // Trigger loading UI

    try {
      final response = await _apiService.addToCart(token, {
        'user_id': userId,
        'item_id': itemId,
        'quantity': quantity,
      });

      print('Raw response from API: $response');

      if (response['success'] == true) {
        await fetchCartItems(token); // Refresh cart
        _error = null;
        print('Item added successfully');
      } else if (response['status'] == 409) {
        _pendingCartItem = {
          'item_id': itemId,
          'quantity': quantity,
        };
        _error =
            'Cart contains items from a different restaurant. Clear cart to proceed.';
        print('Conflict (409): $_error');
        throw Exception(_error);
      } else {
        _error = response['message'] ?? 'Unknown error occurred';
        print('Other error: $_error');
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      print('Exception caught in provider addToCart: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // Reset UI loading state
    }
  }

  void clearPendingCartItemWithoutNotify() {
    _pendingCartItem = null;
    // Tidak memanggil notifyListeners()
  }

  Future<void> fetchCartItems(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getCart(token);
      if (response['success'] == true) {
        _cartItems = (response['data'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
        _error = null;
        print('Cart items fetched successfully: $_cartItems');
      } else {
        throw Exception('Failed to fetch cart items: ${response['message']}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error in fetchCartItems: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkRestaurantMatch(
      String token, int itemId, int restaurantId) async {
    if (_cartItems.isEmpty) {
      await fetchCartItems(token); // Pastikan data keranjang terbaru
    }
    if (_cartItems.isEmpty)
      return true; // Jika keranjang kosong, tidak ada konflik

    // Ambil restaurant_id dari item pertama di keranjang
    final existingRestaurantId = _cartItems.first.item.restaurantId;
    return existingRestaurantId == restaurantId;
  }

  void setPendingCartItem(int itemId, int quantity) {
    _pendingCartItem = {
      'item_id': itemId,
      'quantity': quantity,
    };
    notifyListeners();
  }

  void clearPendingCartItem() {
    _pendingCartItem = null;
    notifyListeners();
  }

  Future<void> clearCart(String token) async {
    try {
      await _apiService.clearCart(token);
      _cartItems = [];
      _error = null;
      notifyListeners();
      print('Cart cleared successfully');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Error clearing cart: $e');
    }
  }

  Future<void> addPendingItemToCart(String token, int userId) async {
    print('Using updated addPendingItemToCart with null-safe handling');
    final pendingItem = _pendingCartItem;
    if (pendingItem == null) {
      print('Pending item is null, exiting addPendingItemToCart');
      return;
    }

    try {
      final itemId = pendingItem['item_id'] as int? ?? 0;
      final quantity = pendingItem['quantity'] as int? ?? 0;

      if (itemId == 0 || quantity == 0) {
        throw Exception('Invalid itemId or quantity in pending item');
      }

      await _apiService.addToCart(token, {
        'user_id': userId,
        'item_id': itemId,
        'quantity': quantity,
      });
      await fetchCartItems(token);
      _pendingCartItem = null;
      _error = null;
      notifyListeners();
      print('Pending item added to cart successfully');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Error adding pending item to cart: $e');
    }
  }

  Future<void> increaseQuantity(String token, int itemId) async {
  _updatingItemId = itemId;
  notifyListeners();
  try {
    final response = await _apiService.increaseCartQuantity(token, itemId);
    if (response['success'] == true) {
      await fetchCartItems(token);
    }
  } catch (e) {
    _error = e.toString();
  } finally {
    _updatingItemId = null;
    notifyListeners();
  }
}

Future<void> decreaseQuantity(String token, int itemId) async {
  _updatingItemId = itemId;
  notifyListeners();
  try {
    final response = await _apiService.decreaseCartQuantity(token, itemId);
    if (response['success'] == true) {
      await fetchCartItems(token);
    }
  } catch (e) {
    _error = e.toString();
  } finally {
    _updatingItemId = null;
    notifyListeners();
  }
}


}
