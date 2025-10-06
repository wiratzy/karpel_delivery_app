// lib/models/admin_restaurant_model.dart

class AdminRestaurant {
  final int id;
  final String name;
  final String? image;
  final double? rate;
  final int? rating;
  final String? type;
  final int? phone;
  final String? foodType;
  final String? location;
  final double? deliveryFee;
  final bool? isMostPopular;
  final int? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final RestaurantOwner? owner;

  AdminRestaurant({
    required this.id,
    required this.name,
    this.image,
    this.rate,
    this.rating,
    this.type,
    this.foodType,
    this.location,
    this.deliveryFee,
    this.isMostPopular,
    this.phone,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.owner,
  });

  factory AdminRestaurant.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values
    num? parseNum(dynamic value) {
      if (value is num) {
        return value;
      } else if (value is String) {
        // Try to parse as double first, then as int if double fails
        return double.tryParse(value) ?? int.tryParse(value);
      }
      return null;
    }

    return AdminRestaurant(
      id: parseNum(json['id'])?.toInt() ?? 0, // Pastikan ID di-parse sebagai int
      name: json['name'] ?? '', // Pastikan name tidak null
      image: json['image'], // Image bisa null atau string URL
      rate: parseNum(json['rate'])?.toDouble(), // Menggunakan helper
      rating: parseNum(json['rating'])?.toInt(), // Menggunakan helper
      type: json['type'],
      foodType: json['food_type'],
      phone: parseNum(json['phone'])?.toInt(), // Menggunakan helper
      location: json['location'],
      deliveryFee: parseNum(json['delivery_fee'])?.toDouble(), // Menggunakan helper
      isMostPopular: json['is_most_popular'] == 1 || json['is_most_popular'] == true, // Handle boolean from int or bool
      ownerId: parseNum(json['owner_id'])?.toInt(), // Menggunakan helper
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
      owner: json['owner'] != null ? RestaurantOwner.fromJson(json['owner']) : null,
    );
  }

  AdminRestaurant copyWith({
    int? id,
    String? name,
    String? image,
    double? rate,
    int? rating,
    String? type,
    String? foodType,
    String? location,
    double? deliveryFee,
    bool? isMostPopular,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    RestaurantOwner? owner,
  }) {
    return AdminRestaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      rate: rate ?? this.rate,
      rating: rating ?? this.rating,
      type: type ?? this.type,
      foodType: foodType ?? this.foodType,
      location: location ?? this.location,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isMostPopular: isMostPopular ?? this.isMostPopular,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      owner: owner ?? this.owner,
    );
  }
}

class RestaurantOwner {
  final int id;
  final String name;
  final String email;
  final String? phone;

  RestaurantOwner({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory RestaurantOwner.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values
    num? parseNum(dynamic value) {
      if (value is num) {
        return value;
      } else if (value is String) {
        return double.tryParse(value) ?? int.tryParse(value);
      }
      return null;
    }

    return RestaurantOwner(
      id: parseNum(json['id'])?.toInt() ?? 0, // Pastikan ID di-parse sebagai int
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'], // Phone bisa string atau null
    );
  }
}