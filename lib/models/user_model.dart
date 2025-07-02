import 'package:kons2/cofing.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? photo;
  final String role;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.photo,
    required this.role,
    required this.latitude,
    required this.longitude,
  });

  /// Factory constructor yang sudah diperbaiki untuk menangani parsing dengan aman.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      photo:
          json['photo'] != null && json['photo'].toString().startsWith('http')
              ? json['photo']
              : json['photo'] != null
                  ? '$baseUrl/storage/photos/${json['photo']}'
                  : null,
      role: json['role'] ?? '',
      latitude: double.tryParse(
          (json['latitude'] ?? json['address_latitude'])?.toString() ?? ''),
      longitude: double.tryParse(
          (json['longitude'] ?? json['address_longitude'])?.toString() ?? ''),
    );
  }

  /// Fungsi toJson yang sudah diperbaiki dengan menyertakan 'id'.
  Map<String, dynamic> toJson() {
    return {
      // PENTING: Tambahkan 'id' agar ikut tersimpan di SharedPreferences
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photo': photo,
      'role': role,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
