class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? photo;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.photo,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      photo: json['photo'],
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photo': photo,
      'role': role,
    };
  }
}
