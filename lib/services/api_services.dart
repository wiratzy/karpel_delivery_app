import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kons2/models/driver_model.dart';
import 'package:kons2/models/home_model.dart';
import 'package:kons2/models/order_model.dart';
import 'package:kons2/models/user_model.dart';

class ApiService {
  // static const String baseUrl = 'http://192.168.239.220:8000/api';
  // static const String baseUrl = 'http://10.0.162.47:8000/api';
  static const String baseUrl = 'http://202.155.132.96/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String password,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Register gagal: ${response.body}');
    }
  }

  Future<User> getUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print(jsonEncode(response.body));
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Gagal mengambil data user: ${response.body}');
    }
  }

  Future<User> updateUser({
    required String token,
    required String name,
    required String email,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    String? password,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'address_latitude': latitude, // ubah dari 'latitude'
        'address_longitude': longitude, // ubah dari 'longitude'
        if (password != null) 'password': password,
        if (password != null) 'password_confirmation': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Gagal memperbarui user: ${response.body}');
    }
  }

  Future<User> uploadPhoto(String token, File photo) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/photo'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('photo', photo.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(responseBody)['user']);
    } else {
      throw Exception('Gagal mengupload foto: $responseBody');
    }
  }

  Future<List<User>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/users/customer'), // Asumsikan endpoint untuk semua user
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['users'] as List)
            .map((json) => User.fromJson(json))
            .where((user) => user.role.toLowerCase() == 'customer')
            .toList();
      } else {
        throw Exception('Failed to load users: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<List<User>> searchUsers(String token, String email) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/users/search?email=$email'), // Asumsikan endpoint pencarian
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['users'] as List)
            .map((json) => User.fromJson(json))
            .where((user) => user.role.toLowerCase() == 'customer')
            .toList();
      } else {
        throw Exception('Failed to search users: ${data['message']}');
      }
    } else {
      throw Exception('Failed to search users: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getHomeData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/home'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      } else {
        throw Exception('Invalid response format: Expected a map');
      }
    } else {
      throw Exception(
          'Failed to fetch home data: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/items/categories'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['categories'] as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    }
  }

  // Future<List<Map<String, dynamic>>> getCategories(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/user/home/categories'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return (data['categories'] as List).cast<Map<String, dynamic>>();
  //   } else {
  //     throw Exception('Failed to fetch categories: ${response.statusCode}');
  //   }
  // }

  // Future<Map<String, dynamic>> getPopularRestaurants(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/user/popular-restaurants'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to fetch popular restaurants: ${response.statusCode}');
  //   }
  // }

  // Future<Map<String, dynamic>> getMostPopularRestaurants(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/user/most-popular-restaurants'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to fetch most popular restaurants: ${response.statusCode}');
  //   }
  // }

  // Future<List<Map<String, dynamic>>> getRecentItems(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/user/recent-items'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to fetch recent items: ${response.statusCode}');
  //   }
  // }
  Future<List<dynamic>> getItemsByCategory(String token, int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/items/category/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] && json['items'] != null) {
        return json['items'] as List<dynamic>;
      } else {
        throw Exception(
            'Failed to fetch items: ${json['message'] ?? 'No items'}');
      }
    } else {
      throw Exception('Failed to fetch items: HTTP ${response.statusCode}');
    }
  }

  // Ambil detail item
  Future<Item> fetchItemDetails(String token, int itemId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/item/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success']) {
        return Item.fromJson(json['data']);
      } else {
        throw Exception(json['message']);
      }
    } else {
      throw Exception('Failed to fetch item details: ${response.statusCode}');
    }
  }

  // Tambah item ke keranjang
  Future<Map<String, dynamic>> addToCart(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody is Map<String, dynamic>) {
          return responseBody;
        } else {
          return {
            'success': false,
            'message': 'Invalid response format (not a JSON object)'
          };
        }
      } else {
        final errorMessage = responseBody is Map<String, dynamic>
            ? responseBody['message'] ?? 'Unknown error'
            : 'Invalid JSON response';

        return {
          'success': false,
          'status': response.statusCode,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('Exception in addToCart API: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Get cart response: $response'); // Debugging
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Raw response from fetchCartItems: $data');
      return data;
    } else {
      throw Exception(
          'Failed to fetch cart items: Status ${response.statusCode}');
    }
  }

  Future<void> clearCart(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }

  Future<Map<String, dynamic>> increaseCartQuantity(
      String token, int itemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/cart/increase'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'item_id': itemId.toString()},
    );

    print('Increase quantity response: $response');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Raw response from increaseCartQuantity: $data');
      return data;
    } else {
      throw Exception(
          'Failed to increase quantity: Status ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> decreaseCartQuantity(
      String token, int itemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/cart/decrease'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'item_id': itemId.toString()},
    );

    print('Decrease quantity response: $response');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Raw response from decreaseCartQuantity: $data');
      return data;
    } else {
      throw Exception(
          'Failed to decrease quantity: Status ${response.statusCode}');
    }
  }

  // --- 1. Fetch Item Categories ---
  Future<List<ItemCategory>> fetchItemCategories(
      {required String token}) async {
    final url = Uri.parse('$baseUrl/user/items-categories');

    // Periksa apakah endpoint ini memerlukan token atau tidak di backend
    // Jika perlu:
    // final response = await http.get(url, headers: {
    //   'Accept': 'application/json',
    //   'Authorization': 'Bearer $token', // Ganti $token dengan token yang valid
    // });
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization':
          'Bearer $token', // <--- AKTIFKAN DAN GUNAKAN TOKEN DI SINI
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> jsonList = responseData['data'];
      return jsonList.map((json) => ItemCategory.fromJson(json)).toList();
    } else {
      print(
          'Failed to load item categories: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal memuat kategori item: ${response.body}');
    }
  }

  // --- 2. Fetch Items with Pagination, Category Filter, and Search Filter ---
  Future<Map<String, dynamic>> fetchItems({
    required String token, // Token autentikasi
    int page = 1,
    int limit = 10,
    String? categoryId, // Untuk filter kategori
    String? searchQuery, // Untuk filter pencarian
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['item_category_id'] = categoryId;
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }

    // Perhatikan: Sesuaikan '/user/items' jika route Anda hanya '/items'
    final uri =
        Uri.parse('$baseUrl/user/items').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> jsonList = responseData['data']; // List data item
      final List<Item> items =
          jsonList.map((json) => Item.fromJson(json)).toList();

      // Mengambil informasi pagination dari 'links' dan 'meta'
      final bool hasMore = responseData['links']['next'] != null;
      final int total = responseData['meta']['total'] as int;

      return {
        'items': items,
        'hasMore': hasMore,
        'total': total,
      };
    } else {
      print('Gagal memuat item: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal memuat item: ${response.body}');
    }
  }

  Future<List<dynamic>> getRestoOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get-orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Response body: ${response.body}');

      if (data['success'] == true && data['orders'] != null) {
        return data['orders'] as List<dynamic>;
      } else {
        // Tetap kembalikan List kosong agar tidak error
        return [];
      }
    } else {
      throw Exception('Terjadi kesalahan server (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> getOrderById(String token, int orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/orders/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint('🧾 Response body: ${response.body}');
    debugPrint('📦 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['order'];
      if (data == null) {
        throw Exception('Respons tidak berisi data');
      }
      return data;
    } else {
      throw Exception('Gagal mengambil detail pesanan');
    }
  }

  // PUT /orders/{id}/status
  Future<void> updateOrderStatus(
      String token, int orderId, String newStatus) async {
    final response = await http.put(
      Uri.parse('$baseUrl/restaurants/orders/$orderId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengubah status');
    }
  }

  Future<Map<String, dynamic>> checkout(String token, Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('$baseUrl/checkout'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body); // sukses, return responsenya
  } else {
    throw Exception('Gagal melakukan checkout: ${response.body}');
  }
}

Future<List<dynamic>> getMyOrders(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/user/my-orders'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    print("📦 getMyOrders: ${body['data']}");
    return body['data']; // HANYA KEMBALIKAN DATA-NYA
  } else {
    throw Exception('Gagal mengambil daftar pesanan: ${response.statusCode}');
  }
}



Future<Map<String, dynamic>> getCustomerOrderById(String token, int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/user/orders/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body['data']; // Kembalikan data pesanan
  } else {
    throw Exception('Gagal mengambil detail pesanan: ${response.statusCode}');
  }
}
Future<void> updateCustomerOrderStatus(String token, int orderId, String status) async {
  final url = Uri.parse('$baseUrl/user/orders/$orderId/status');
  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'status': status}),
  );

  if (response.statusCode != 200) {
    throw Exception('Gagal update status');
  }
}

// services/api_service.dart
Future<void> assignDriverToOrder({
  required int orderId,
  required int driverId,
  required String token,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/restaurants/orders/$orderId/assign-driver'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'driver_id': driverId,
    }),
  );

  print('Assign Driver Response: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Gagal assign driver: ${response.body}');
  }
}

 Future<List<Driver>> getAvailableDrivers(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/restaurants/drivers'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  print('Response Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((driver) => Driver.fromJson(driver))
        .toList();
  } else {
    throw Exception('Gagal mengambil daftar driver: ${response.statusCode}');
  }
}


}
