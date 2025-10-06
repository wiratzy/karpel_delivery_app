// lib/providers/AdminRestaurantApplicationProvider.dart

import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/restaurant_aplication.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';

class AdminRestaurantApplicationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  final Map<String, List<RestaurantApplication>> _applicationsByStatus = {};
  final Map<String, bool> _isLoadingInitial = {};
  final Map<String, bool> _isLoadingMore = {};
  final Map<String, bool> _hasMore = {};
  final Map<String, int> _currentPage = {};
  final Map<String, String?> _errors = {};

  final List<String> _availableStatuses = [
    'all',
    'pending',
    'approved',
    'rejected',
  ];

  List<RestaurantApplication> getApplicationsForStatus(String status) =>
      _applicationsByStatus[status] ?? [];

  bool isLoading(String status) => _isLoadingInitial[status] ?? false;
  bool isLoadingMore(String status) => _isLoadingMore[status] ?? false;
  bool hasMore(String status) => _hasMore[status] ?? true;
  String? getError(String status) => _errors[status];

  final int _perPage = 10;
  String _token = '';

  // Inisialisasi provider: muat token dan panggil fetch untuk setiap status
  Future<void> init() async {
    _token = await _storageService.getToken() ?? '';
    if (_token.isEmpty) {
      _errors['all'] = "Token autentikasi tidak tersedia. Mohon login ulang.";
      notifyListeners();
      return;
    }

    // Inisialisasi map untuk setiap status jika belum ada
    for (String status in _availableStatuses) {
      _applicationsByStatus.putIfAbsent(status, () => []);
      _isLoadingInitial.putIfAbsent(status, () => false);
      _isLoadingMore.putIfAbsent(status, () => false);
      _hasMore.putIfAbsent(status, () => true);
      _currentPage.putIfAbsent(status, () => 1);
      _errors.putIfAbsent(status, () => null);

      // Panggil fetch untuk setiap status saat inisialisasi
      // Pastikan hanya memanggil jika belum pernah dimuat sebelumnya
      if (_applicationsByStatus[status]!.isEmpty &&
          !_isLoadingInitial[status]!) {
        await fetchApplications(status: status, reset: true);
      }
    }
  }

  // Metode untuk mengambil aplikasi berdasarkan status
  Future<void> fetchApplications(
      {required String status, bool reset = false}) async {
    if (reset) {
      _applicationsByStatus[status] = [];
      _currentPage[status] = 1;
      _hasMore[status] = true;
      _errors[status] = null;
    }

    if (isLoading(status) ||
        (isLoadingMore(status) && !reset) ||
        !hasMore(status)) return;

    _isLoadingInitial[status] = true;
    _errors[status] = null; // Bersihkan error sebelumnya
    notifyListeners();

    try {
      final List<RestaurantApplication> newData;
      final String? apiStatusParam = (status == 'all')
          ? null
          : status; // Jika 'all', tidak ada filter status

      if (status == 'all') {
        newData = await _apiService.fetchRestaurantApplications(
          _token,
          page: _currentPage[status]!,
          limit: _perPage,
        );
      } else {
        newData = await _apiService.fetchRestaurantApplications(
          _token,
          page: _currentPage[status]!,
          limit: _perPage,
          statusFilter: apiStatusParam, // Kirim filter status ke API
        );
      }

      _applicationsByStatus[status]!.addAll(newData);
      _hasMore[status] = newData.length ==
          _perPage; // Asumsi ini masih digunakan untuk hasMore
      _currentPage[status] = _currentPage[status]! + 1; // Naikkan halaman
    } catch (e) {
      _errors[status] = e.toString();
      _hasMore[status] = false; // Jika ada error, anggap tidak ada lagi data
      print("Error fetching applications for status $status: $e");
    } finally {
      _isLoadingInitial[status] = false;
      notifyListeners();
    }
  }

  // Metode untuk memuat lebih banyak aplikasi berdasarkan status
  Future<void> loadMoreApplications({required String status}) async {
    if (_token.isEmpty) {
      _errors[status] = "Token tidak tersedia untuk load more.";
      notifyListeners();
      return;
    }

    if (!hasMore(status) || isLoadingMore(status)) return;

    _isLoadingMore[status] = true;
    _errors[status] = null; // Bersihkan error sebelumnya
    notifyListeners();

    try {
      final List<RestaurantApplication> moreData;
      final String? apiStatusParam = (status == 'all')
          ? null
          : status; // Jika 'all', tidak ada filter status
      if (status == 'all') {
        moreData = await _apiService.fetchRestaurantApplications(
          _token,
          page: _currentPage[status]!,
          limit: _perPage,
        );
      } else {
        moreData = await _apiService.fetchRestaurantApplications(
          _token,
          page: _currentPage[status]!,
          limit: _perPage,
          statusFilter: apiStatusParam, // Kirim filter status
        );
      }

      _applicationsByStatus[status]!.addAll(moreData);
      _hasMore[status] = moreData.length == _perPage;
      _currentPage[status] = _currentPage[status]! + 1;
    } catch (e) {
      _errors[status] = e.toString();
      _hasMore[status] = false; // Jika ada error, anggap tidak ada lagi data
      print("Error loading more applications for status $status: $e");
    } finally {
      _isLoadingMore[status] = false;
      notifyListeners();
    }
  }

  // Metode untuk konfirmasi/tolak pengajuan
   Future<bool> confirmApplication(int id) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      _errors['all'] = "Token tidak tersedia untuk konfirmasi.";
      notifyListeners();
      return false;
    }
    try {
      final result = await _apiService.confirmRestaurantApplication(id, token);
      if (result) {
        // Hapus dari semua daftar dan panggil refresh untuk memastikan data konsisten
        // Ini lebih aman daripada hanya removeWhere karena status item berubah
        await refreshAllTabs(); // Refresh semua tab setelah aksi sukses
        return true;
      }
      return false;
    } catch (e) {
      _errors['all'] = e.toString();
      notifyListeners();
      print("Error confirming application: $e");
      return false;
    }
  }

  Future<bool> rejectApplication(int id) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      _errors['all'] = "Token tidak tersedia untuk menolak.";
      notifyListeners();
      return false;
    }
    try {
      final result = await _apiService.rejectRestaurantApplication(id, token);
      if (result) {
        // Hapus dari semua daftar dan panggil refresh untuk memastikan data konsisten
        await refreshAllTabs(); // Refresh semua tab setelah aksi sukses
        return true;
      }
      return false;
    } catch (e) {
      _errors['all'] = e.toString();
      notifyListeners();
      print("Error rejecting application: $e");
      return false;
    }
  }

  // Getter untuk daftar status yang tersedia
  List<String> get availableStatuses => _availableStatuses;

  // Untuk refresh semua tab
  Future<void> refreshAllTabs() async {
    for (String status in _availableStatuses) {
      await fetchApplications(status: status, reset: true);
    }
  }
}
