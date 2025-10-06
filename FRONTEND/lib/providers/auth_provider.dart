import 'dart:io';

import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/user_model.dart';
import '../services/api_services.dart';
import '../services/storage_services.dart';

class AuthProvider extends ChangeNotifier {
  // --- DEPENDENSI ---
  final ApiService _apiService;
  final StorageService _storageService;

  // Constructor yang benar dengan dependency injection
  AuthProvider(this._apiService, this._storageService);

  // --- STATE ---
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isOnboardingCompleted = false;

  // --- GETTER ---
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoggedIn => _token != null;


void setUser(User newUser) {
  _user = newUser;
  notifyListeners();
}

Future<void> fetchUser() async {
  if (_token == null) return;

  final response = await _apiService.fetchUser(token: _token!);
  _user = response;
  await _storageService.saveUser(_user!);
  notifyListeners();
}


  /// **FUNGSI INIT YANG SUDAH DIPERBAIKI**
  /// Memuat sesi pengguna dengan urutan yang benar dan "sadar-role".
  Future<void> init() async {
    _token = await _storageService.getToken();

    if (isLoggedIn) {
      // 1. Ambil data user terlebih dahulu untuk mengetahui role-nya
      _user = await _storageService.getUser();

      // 2. KUNCI PERBAIKAN:
      //    Hanya periksa status onboarding JIKA role-nya adalah 'customer'.
      if (_user?.role == 'customer') {
        _isOnboardingCompleted = await _storageService.getOnboardingStatus();
      } else {
        // Untuk role lain (admin, owner, driver), status onboarding tidak relevan.
        // Kita bisa set ke true agar tidak pernah mengganggu alur navigasi.
        _isOnboardingCompleted = true;
      }
    } else {
      // Jika tidak ada token, reset semua state ke nilai default.
      _user = null;
      _isOnboardingCompleted = false;
    }

    // Memberi tahu listener bahwa proses inisialisasi selesai.
    notifyListeners();
  }

  /// Menandai bahwa customer telah menyelesaikan onboarding.
  Future<void> completeOnboarding() async {
    // Pastikan hanya customer yang bisa memanggil ini.
    if (_user?.role == 'customer') {
      _isOnboardingCompleted = true;
      await _storageService.saveOnboardingStatus(true);
      notifyListeners();
    }
  }

  /// Mengelola state setelah login berhasil.
  Future<void> login(String email, String password) async {
  _isLoading = true;
  notifyListeners();
  try {
    final response = await _apiService.login(email, password);
    _token = response['token'] as String?;

    // Inject restaurant_id langsung ke dalam user map
    final userMap = Map<String, dynamic>.from(response['user']);
    userMap['restaurant_id'] = response['restaurant_id'];

    _user = User.fromJson(userMap);

    print("🧾 Login user data: $userMap");
    print("✅ Parsed restaurantId: ${_user?.restaurantId}");

    if (isLoggedIn) {
      await _storageService.saveToken(_token!);
      await _storageService.saveUser(_user!);

      if (_user?.role == 'customer') {
        await _storageService.saveOnboardingStatus(false);
        _isOnboardingCompleted = false;
      }
    } else {
      throw Exception('Login gagal: Token tidak diterima dari server.');
    }
  } catch (e) {
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  /// Mengelola state setelah registrasi berhasil.
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      _token = response['token'] as String?;
      _user = User.fromJson(response['user']);

      if (isLoggedIn) {
        await _storageService.saveToken(_token!);
        await _storageService.saveUser(_user!);
        // Pengguna baru (customer) pasti belum onboarding.
        await _storageService.saveOnboardingStatus(false);
        _isOnboardingCompleted = false;
      } else {
        throw Exception('Registrasi gagal: Token tidak diterima dari server.');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Membersihkan semua sesi dan state saat logout.
  Future<void> logout() async {
    _token = null;
    _user = null;
    // Jangan reset onboarding!
    await _storageService.removeTokenAndUser();
    notifyListeners();
  }

 Future<User> updateUser({
  required String name,
  required String email,
  required String phone,
  required String address,
  required double latitude,
  required double longitude,
  String? password,
  File? photo,
}) async {
  if (_token == null) throw Exception("Token tidak tersedia");

  // 1. Update data dasar user
  final updatedUser = await _apiService.updateUser(
    token: _token!,
    name: name,
    email: email,
    phone: phone,
    address: address,
    latitude: latitude,
    longitude: longitude,
    password: password,
  );

  // 2. Upload foto jika ada
  User finalUser = updatedUser;
  if (photo != null) {
    finalUser = await _apiService.uploadPhoto(_token!, photo);
  }

  // 3. Simpan user baru ke state dan local storage
  _user = finalUser;
  await _storageService.saveUser(_user!);
  notifyListeners();

  return finalUser;
}


  // Anda bisa menambahkan fungsi updateUser di sini jika perlu
}
