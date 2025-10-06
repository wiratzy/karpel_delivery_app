import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:karpel_food_delivery/models/admin_item_category_model.dart';
import 'package:karpel_food_delivery/models/admin_restaurant_model.dart';
import 'package:karpel_food_delivery/models/customer_restaurant_detail_model.dart';
import 'package:karpel_food_delivery/models/customer_restaurant_model.dart';
import 'package:karpel_food_delivery/models/driver_model.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/models/restaurant_aplication.dart';
import 'package:karpel_food_delivery/models/user_model.dart';

class ApiService {
  // static const String baseUrl = 'http://192.168.239.220:8000/api';
  static const String baseUrl = 'http://172.20.10.5:8000/api';
  // static const String baseUrl = 'http://192.168.1.120:8000/api';

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

  Future<User> fetchUser({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Gagal mengambil data user: ${response.body}');
    }
  }

  Future<List<User>> getAllUsers(String token) async {
    // Pastikan endpoint ini benar sesuai dengan rute API admin Anda
    final response = await http.get(
      Uri.parse('$baseUrl/users/customer'), // Ganti jika endpoint Anda berbeda
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Kode ini mengharapkan Map, bukan List
      print(response.statusCode);
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Mengambil list dari dalam key 'users'
        return (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        throw Exception('Gagal memuat pengguna: ${data['message']}');
      }
    } else {
      throw Exception('Gagal memuat pengguna: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/customer/$userId'), // Sesuaikan endpoint
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('Error deleting user: ${response.body}');
      throw Exception(
          'Gagal menghapus pengguna. Status: ${response.statusCode}');
    }
  }

  // Method untuk mengupdate user oleh admin
  Future<User> updateUserByAdmin({
    required String token,
    required int userId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/customer/$userId'), // Sesuaikan endpoint
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      print('Error updating user: ${response.body}');
      throw Exception(
          'Gagal memperbarui pengguna. Status: ${response.statusCode}');
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

  Future<Map<String, dynamic>> checkout(
      String token, Map<String, dynamic> data) async {
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

  Future<Map<String, dynamic>> getCustomerOrderById(
      String token, int id) async {
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

  Future<void> updateCustomerOrderStatus(
    String token,
    int orderId,
    String status, {
    int? restaurantRating,
    int? itemRating,
    String? reviewText,
  }) async {
    final url = Uri.parse('$baseUrl/user/orders/$orderId/status');

    final body = {
      'status': status,
      if (restaurantRating != null) 'restaurant_rating': restaurantRating,
      if (itemRating != null) 'item_rating': itemRating,
          if (reviewText != null && reviewText.isNotEmpty) 'review_text': reviewText, // ✅ tambahin ini

    };

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update status: ${response.body}');
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

  Future<List<Item>> getOwnerItems(String token, {int? categoryId}) async {
    final query = categoryId != null ? '?item_category_id=$categoryId' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants-items$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList();
    } else {
      throw Exception('Gagal memuat data item owner');
    }
  }

  Future<Map<String, dynamic>> createItem({
    required String token,
    required Map<String, String?> data,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/restaurants-items');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final resJson = jsonDecode(resBody);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return resJson;
    } else {
      throw Exception(resJson['message'] ?? 'Gagal membuat item');
    }
  }

  Future<Map<String, dynamic>> updateItem({
    required String token,
    required int itemId,
    required Map<String, String?> data,
    File? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/restaurants-items/$itemId');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT'; // Tambahkan spoof method

    data.forEach((key, value) {
      print('🧪 Sending update item data:');
      print('🧾 $key: $value');

      // Kirim hanya jika tidak null dan tidak kosong
      if (value != null && value.toString().trim().isNotEmpty) {
        request.fields[key] = value;
      }
    });

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal update item: ${response.body}');
    }
  }

  Future<Item> fetchItemDetail({
    required String token,
    required int itemId,
  }) async {
    final url = Uri.parse('$baseUrl/restaurants-items/detail/$itemId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        return Item.fromJson(data['data']);
      } else {
        throw Exception('Item tidak ditemukan dalam response');
      }
    } else {
      throw Exception('Gagal memuat detail item: ${response.body}');
    }
  }

  Future<void> deleteItem({
    required String token,
    required int itemId,
  }) async {
    final url = Uri.parse('$baseUrl/restaurants-items/$itemId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus item: ${response.body}');
    }
  }

  Future<List<Driver>> fetchDrivers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/drivers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => Driver.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil driver');
    }
  }

  Future<Driver> createDriver(String token, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/restaurants/drivers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Driver.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal menambahkan driver');
    }
  }

  Future<Driver> updateDriver(
      String token, int id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/restaurants/drivers/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Driver.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal mengupdate driver');
    }
  }

  Future<void> deleteDriver(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/restaurants/drivers/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus driver');
    }
  }

   Future<List<AdminRestaurant>> fetchAdminRestaurants(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/restaurants"),
      headers: {"Authorization": "Bearer $token"},
    );
    print('Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Perbaikan di sini: Akses data['data']['data']
      return (data['data']['data'] as List) // <-- Perbaikan kunci 'data'
          .map((e) => AdminRestaurant.fromJson(e))
          .toList();
    } else {
      throw Exception("Gagal memuat daftar restoran: ${response.statusCode} ${response.body}");
    }
  }

  Future<AdminRestaurant> fetchAdminRestaurantById(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/restaurants/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Pastikan struktur respons juga di sini jika detail juga ada 'data' wrapper
      // Laravel show method untuk single resource biasanya langsung mengembalikan resource atau resource dalam 'data'
      final data = jsonDecode(response.body);
      return AdminRestaurant.fromJson(data['data']); // Asumsi data single resource ada di 'data'
    } else {
      throw Exception('Gagal mengambil detail restoran: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> createAdminRestaurant(
    String token,
    Map<String, String> fields,
    File? imagePath,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/admin/restaurants"),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imagePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imagePath.path));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString(); // Tangkap body untuk debugging

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambahkan restoran: ${response.statusCode} $responseBody');
    }
    print('Create Restaurant Success: $responseBody'); // Debugging sukses
  }

  Future<void> updateAdminRestaurant(
    String token,
    int id,
    Map<String, String> fields,
    File? imagePath,
  ) async {
    var request = http.MultipartRequest(
      'POST', // Tetap POST, tapi pakai _method=PUT
      Uri.parse("$baseUrl/admin/restaurants/$id?_method=PUT"),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imagePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imagePath.path));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString(); // Tangkap body untuk debugging

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui restoran: ${response.statusCode} $responseBody');
    }
    print('Update Restaurant Success: $responseBody'); // Debugging sukses
  }

  Future<void> deleteAdminRestaurant(String token, int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/restaurants/$id"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus restoran: ${response.statusCode} ${response.body}');
    }
    print('Delete Restaurant Success: ${response.body}'); // Debugging sukses
  }

  Future<List<AdminItemCategory>> fetchAdminItemCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin-item-categories'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((e) => AdminItemCategory.fromJson(e))
          .toList();
    } else {
      throw Exception('Gagal memuat kategori item');
    }
  }

  // POST: Create new category with image (multipart)
  Future<void> createAdminItemCategory(
      String token, Map<String, String> fields, File? image) async {
    final uri = Uri.parse('$baseUrl/admin-item-categories');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    fields.forEach((key, value) => request.fields[key] = value);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambah kategori');
    }
  }

  // PUT: Update existing category with image
  Future<void> updateAdminItemCategory(
      String token, int id, Map<String, String> fields, File? image) async {
    final uri = Uri.parse('$baseUrl/admin-item-categories/$id');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['_method'] = 'PUT';

    fields.forEach((key, value) => request.fields[key] = value);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Gagal mengubah kategori');
    }
  }

  // DELETE
  Future<void> deleteAdminItemCategory(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin-item-categories/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus kategori');
    }
  }

  Future<List<CustomerRestaurant>> fetchCustomerRestaurants(
    String token, {
    String? search,
    int? rate,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (rate != null) {
        queryParameters['rate'] = rate.toString();
      }

      final uri = Uri.parse('$baseUrl/user/restaurants')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data'];
        return data.map((r) => CustomerRestaurant.fromJson(r)).toList();
      } else {
        throw Exception('Gagal memuat daftar restoran');
      }
    } catch (e) {
      throw Exception('fetchCustomerRestaurants error: $e');
    }
  }

  Future<CustomerRestaurantDetail> fetchCustomerRestaurantDetail(
      String token, int restaurantId) async {
    final url = Uri.parse('$baseUrl/user/restaurants/$restaurantId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return CustomerRestaurantDetail.fromJson(data['data']);
    } else {
      throw Exception(
          "fetchCustomerRestaurantDetail error: ${data['message'] ?? response.body}");
    }
  }

 Future<List<RestaurantApplication>> fetchRestaurantApplications(
  String token, {
  int page = 1,
  int limit = 10,
  String? statusFilter
}) async {

   Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
      queryParams['status'] = statusFilter; 
    }

        final uri = Uri.parse('$baseUrl/admin/restaurant-applications').replace(queryParameters: queryParams);

  final response = await http.get(
      uri, 
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
      final List<dynamic> apps = data['data']['data']; 
      print('Fetched ${apps.length} restaurant applications for status: $statusFilter'); // Debugging print
      print('URL called: $uri'); // Debugging print

      return apps.map((e) => RestaurantApplication.fromJson(e)).toList();
    } else {
      throw Exception(
        "fetchRestaurantApplications error: ${data['message'] ?? response.body}");
    }
}


    Future<bool> confirmRestaurantApplication(int id, String token) async {
    final uri = Uri.parse('$baseUrl/admin/restaurant-applications/$id/approve');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      print("Application $id confirmed successfully.");
      return true;
    } else {
      throw Exception(
          "Failed to confirm application ${id}: ${data['message'] ?? response.body}");
    }
  }

  // --- Metode baru untuk menolak pengajuan ---
  Future<bool> rejectRestaurantApplication(int id, String token) async {
    final uri = Uri.parse('$baseUrl/admin/restaurant-applications/$id/reject');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      print("Application $id rejected successfully.");
      return true;
    } else {
      throw Exception(
          "Failed to reject application ${id}: ${data['message'] ?? response.body}");
    }
  }
}
