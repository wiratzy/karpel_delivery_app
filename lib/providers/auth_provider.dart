import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kons2/models/user_model.dart';
import '../services/api_services.dart';
import '../services/storage_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService = StorageService();
  AuthProvider(this._apiService);

  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isOnboardingCompleted = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  Future<void> init() async {
    _token = await _storageService.getToken();
    print('Token from storage: $_token');
    final prefs = await SharedPreferences.getInstance();
    _isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
    print('Onboarding completed status: $_isOnboardingCompleted');
    if (_token != null) {
      try {
        _user = await _apiService.getUser(_token!);
        print('User fetched: ${_user?.toJson()}');
      } catch (e) {
        print('Error fetching user: $e');
        _token = null;
        await _storageService.removeToken();
        _user = null;
      }
    } else {
      print('No token found in storage');
    }
    notifyListeners();
  }

  void setOnboardingCompleted(bool value) {
    _isOnboardingCompleted = value;
    notifyListeners();
  }
  void setUserForTesting(User user) {
  _user = user;
  notifyListeners();
}

  Future<void> login(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.login(email, password);
      print('Login Response: $response');
      _token = response['token'] as String?;
      final userData = response['user'];
      _user = userData != null ? User.fromJson(userData) : null;
      if (_token != null) {
        await _storageService.saveToken(_token!);
        if (_user != null) {
          await _storageService.saveUser(_user!);
        }
        await _saveLoginStatus(true);
        final prefs = await SharedPreferences.getInstance();
        _isOnboardingCompleted =
            prefs.getBool('isOnboardingCompleted') ?? false;
        print('Login - isOnboardingCompleted: $_isOnboardingCompleted');
        if (_user?.role == 'customer') {
          if (!_isOnboardingCompleted) {
            print('Navigating to OnBoardingView');
            Navigator.pushReplacementNamed(context, '/onBoarding');
          } else {
            print('Navigating to MainTabview');
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          switch (_user?.role) {
            case 'admin':
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case 'restaurant_owner':
              Navigator.pushReplacementNamed(context, '/restaurantOwner');
              break;
            case 'driver':
              Navigator.pushReplacementNamed(context, '/driver');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/main');
              break;
          }
        }
      } else {
        throw Exception('Token tidak ditemukan di response');
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address, // Formatted address
    required double latitude,
    required double longitude,
    bool autoLogin = false,
    BuildContext? context,
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

      print('Register Response: $response');
      _token = response['token'] as String?;
      final userData = response['user'];
      _user = userData != null ? User.fromJson(userData) : null;

      if (_token != null) {
        await _storageService.saveToken(_token!);
        if (_user != null) {
          await _storageService.saveUser(_user!);
        }
        if (autoLogin && context != null) {
          await _saveLoginStatus(true);
          final prefs = await SharedPreferences.getInstance();
          _isOnboardingCompleted =
              prefs.getBool('isOnboardingCompleted') ?? false;

          if (_user?.role == 'customer') {
            if (!_isOnboardingCompleted) {
              Navigator.pushReplacementNamed(context, '/onBoarding');
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          } else {
            switch (_user?.role) {
              case 'admin':
                Navigator.pushReplacementNamed(context, '/admin');
                break;
              case 'restaurant_owner':
                Navigator.pushReplacementNamed(context, '/restaurantOwner');
                break;
              case 'driver':
                Navigator.pushReplacementNamed(context, '/driver');
                break;
              default:
                Navigator.pushReplacementNamed(context, '/main');
                break;
            }
          }
        }
      } else {
        throw Exception('Token tidak ditemukan di response');
      }
    } catch (e) {
      print('Register Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser({
  required String name,
  required String email,
  required String phone,
  required String address,
  required double latitude,
  required double longitude,
  String? password,
  File? photo,
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    if (_token == null) throw Exception('Tidak ada token autentikasi');

    // Kirim data update user ke API
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
    _user = updatedUser;

    // Upload foto jika ada
    if (photo != null) {
      final photoUser = await _apiService.uploadPhoto(_token!, photo);
      _user = photoUser;
      print('Photo User Updated: ${photoUser.toJson()}');
    }

    // Simpan user terbaru ke storage
    if (_user != null) {
      await _storageService.saveUser(_user!);
    }
  } catch (e) {
    print('Update User Error: $e');
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = null;
      _token = null;
      await _storageService.removeToken();
      await _storageService.removeUser();
      await _saveLoginStatus(false);
    } catch (e) {
      print('Logout Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }
}
