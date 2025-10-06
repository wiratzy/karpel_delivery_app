import 'dart:io';

import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/admin_restaurant_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';

class AdminRestaurantProvider extends ChangeNotifier {
  final ApiService apiService;
  AdminRestaurantProvider({required this.apiService});

  final StorageService _storageService = StorageService();
  List<AdminRestaurant> _restaurants = []; // Daftar semua restoran (cached)
  List<AdminRestaurant> _filteredRestaurants = []; // Daftar restoran yang ditampilkan (setelah filter/search)
  List<AdminRestaurant> get restaurants => _filteredRestaurants; // Getter untuk filtered list

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage; // Untuk menyimpan pesan error
  String? get errorMessage => _errorMessage;

  String _token = '';

  Future<void> init() async {
    _isLoading = true; // Set loading true di awal init
    _errorMessage = null; // Bersihkan error sebelumnya
    notifyListeners(); // Beritahu listener bahwa loading dimulai

    _token = await _storageService.getToken() ?? '';
    if (_token.isEmpty) {
      _errorMessage = "Autentikasi diperlukan. Mohon login ulang.";
      _isLoading = false;
      notifyListeners();
      return;
    }
    await fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _errorMessage = null; // Bersihkan error
    notifyListeners(); // Beritahu listener bahwa loading dimulai

    if (_token.isEmpty) {
      _errorMessage = "Token autentikasi tidak tersedia.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final data = await apiService.fetchAdminRestaurants(_token);
      _restaurants = data; // Simpan semua data
      _filteredRestaurants = data; // Filtered list juga diset semua data awal
    } catch (e) {
      print('❌ fetchRestaurants error: $e');
      _errorMessage = "Gagal memuat daftar restoran: ${e.toString()}"; // Simpan pesan error
    } finally {
      _isLoading = false;
      notifyListeners(); // Beritahu listener bahwa loading selesai (baik berhasil atau error)
    }
  }

  Future<AdminRestaurant?> fetchRestaurantDetail(int id) async {
    // Tidak perlu set _isLoading = true atau notifyListeners di sini
    // karena ini adalah detail tunggal dan biasanya dipanggil di halaman detail yang terpisah
    try {
      if (_token.isEmpty) {
        _errorMessage = "Token autentikasi tidak tersedia.";
        notifyListeners();
        return null;
      }
      return await apiService.fetchAdminRestaurantById(_token, id);
    } catch (e) {
      print('❌ fetchRestaurantDetail error: $e');
      _errorMessage = "Gagal memuat detail restoran: ${e.toString()}";
      notifyListeners(); // Notify jika ada error di detail
      return null;
    }
  }

  Future<void> addRestaurant(Map<String, String> fields, File? image) async {
    _isLoading = true; // Set loading saat aksi
    _errorMessage = null;
    notifyListeners();
    try {
      await apiService.createAdminRestaurant(_token, fields, image);
      await fetchRestaurants(); // Refresh daftar setelah berhasil
    } catch (e) {
      _errorMessage = "Gagal menambah restoran: ${e.toString()}";
      notifyListeners();
      rethrow; // Lempar kembali error agar UI bisa menampilkan SnackBar/dialog
    } finally {
      _isLoading = false; // Pastikan loading false di akhir
      // notifyListeners(); // fetchRestaurants sudah memanggil notifyListeners
    }
  }

  Future<void> editRestaurant(int id, Map<String, String> fields, File? image) async {
    _isLoading = true; // Set loading saat aksi
    _errorMessage = null;
    notifyListeners();
    try {
      await apiService.updateAdminRestaurant(_token, id, fields, image);
      await fetchRestaurants(); // Refresh daftar setelah berhasil
    } catch (e) {
      _errorMessage = "Gagal mengedit restoran: ${e.toString()}";
      notifyListeners();
      rethrow; // Lempar kembali error
    } finally {
      _isLoading = false;
      // notifyListeners();
    }
  }

  Future<void> deleteRestaurant(int id) async {
    _isLoading = true; // Set loading saat aksi
    _errorMessage = null;
    notifyListeners();
    try {
      await apiService.deleteAdminRestaurant(_token, id);
      await fetchRestaurants(); // Refresh daftar setelah berhasil
    } catch (e) {
      _errorMessage = "Gagal menghapus restoran: ${e.toString()}";
      notifyListeners();
      rethrow; // Lempar kembali error
    } finally {
      _isLoading = false;
      // notifyListeners();
    }
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      _filteredRestaurants = _restaurants; // Kembali ke daftar asli jika keyword kosong
    } else {
      _filteredRestaurants = _restaurants.where((r) {
        // Melakukan pencarian di field yang relevan, termasuk dari objek owner
        final nameMatch = r.name.toLowerCase().contains(keyword.toLowerCase());
        final locationMatch = r.location?.toLowerCase().contains(keyword.toLowerCase()) ?? false;
        final typeMatch = r.type?.toLowerCase().contains(keyword.toLowerCase()) ?? false;
        final foodTypeMatch = r.foodType?.toLowerCase().contains(keyword.toLowerCase()) ?? false;

        // Pencarian di owner (jika owner tidak null)
        final ownerNameMatch = r.owner?.name.toLowerCase().contains(keyword.toLowerCase()) ?? false;
        final ownerEmailMatch = r.owner?.email.toLowerCase().contains(keyword.toLowerCase()) ?? false;

        return nameMatch || locationMatch || typeMatch || foodTypeMatch || ownerNameMatch || ownerEmailMatch;
      }).toList();
    }
    notifyListeners(); // Beritahu listener bahwa daftar telah diperbarui
  }
}