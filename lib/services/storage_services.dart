import 'dart:convert';
import 'package:kons2/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service ini bertanggung jawab untuk semua operasi baca/tulis
/// ke penyimpanan lokal perangkat (SharedPreferences).
class StorageService {

  // --- Token ---
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- User ---
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // --- Onboarding ---
  Future<void> saveOnboardingStatus(bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingCompleted', isCompleted);
  }

  Future<bool> getOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Default ke false jika belum pernah ada
    return prefs.getBool('isOnboardingCompleted') ?? false;
  }

  // --- Operasi Gabungan (Cleanup) ---

  /// Menghapus token dan data user, biasanya untuk logout.
  Future<void> removeTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
