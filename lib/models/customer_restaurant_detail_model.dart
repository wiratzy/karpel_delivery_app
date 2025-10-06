import 'package:karpel_food_delivery/models/review_model.dart';

import 'home_model.dart'; // Untuk re-use model Item

class CustomerRestaurantDetail {
  final int id;
  final String name;
  final String location;
  final String? phone;
  final String type;
  final String? rate;
  final int? rating;
  final String? foodType;
  final String image;
  final List<Item> items;
  final List<String> categories;
    final List<Review> reviews; // ✅ baru


  CustomerRestaurantDetail({
    required this.id,
    required this.name,
    required this.location,
    this.phone,
    required this.type,
    this.rate,
    this.rating,
    this.foodType,
    required this.image,
    required this.items,
    required this.categories,
    required this.reviews,
  });

  factory CustomerRestaurantDetail.fromJson(Map<String, dynamic> json) {
    return CustomerRestaurantDetail(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      phone: json['phone'],
      type: json['type'],
      rate: json['rate']?.toString(),
      rating: json['rating'],
      foodType: json['food_type'],
      image: json['image'],
      items: (json['items'] as List<dynamic>)
          .map((e) => Item.fromJson(e))
          .toList(),
      categories: List<String>.from(json['categories'] ?? []),
       reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((r) => Review.fromJson(r))
          .toList(), // ✅ parse reviews
    );
  }
}
