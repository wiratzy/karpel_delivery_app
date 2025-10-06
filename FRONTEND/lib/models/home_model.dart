import 'package:karpel_food_delivery/cofing.dart';

class Restaurant {
  final int id;
  final String name;
  final String image;
  final double rate;
  final int rating;
  final String type;
  final String? foodType;
  final String? location;
  final double deliveryFee;
  Restaurant.dummy()
      : id = 0,
        name = "Restaurant Name",
        image = "",
        rate = 4.5,
        rating = 50,
        type = "Type",
        foodType = "Food Type",
        location = "Location",
        deliveryFee = 5000;

  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.rate,
    required this.rating,
    required this.type,
    this.foodType,
    this.location,
    required this.deliveryFee,
  });

  

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        rate: _parseRate(json['rate']),
        rating: json['rating'] is int
            ? json['rating']
            : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
        type: json['type'] ?? '',
        foodType: json['food_type'],
        location: json['location'],
        deliveryFee:
            double.tryParse(json['delivery_fee']?.toString() ?? '0.0') ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'rate': rate,
        'rating': rating,
        'type': type,
        'food_type': foodType,
        'location': location,
        'delivery_fee': deliveryFee,
      };

  static double _parseRate(dynamic rate) {
    if (rate is num) return rate.toDouble();
    if (rate is String) return double.tryParse(rate) ?? 0.0;
    return 0.0;
  }
}

class Item {
  final int id;
  final String name;
  final String image;
  final Restaurant restaurant;
  final String rate;
  final int rating;
  final String type;
  final String? price;
  final int? itemCategoryId;
  final int? restaurantId;
    final ItemCategory? itemCategory; 
      final String? categoryName; 



  Item({
    required this.id,
    required this.name,
    required this.image,
    required this.restaurant,
    required this.rate,
    required this.rating,
    required this.type,
    required this.price,
    this.itemCategoryId,
    this.restaurantId,
    this.itemCategory,
    this.categoryName,
  });
factory Item.dummy() {
  return Item(
    id: 0,
    name: 'Item Name',
    image: '',
    rate: '0.0',
    rating: 0,
    type: 'Item Type',
    price: '0',
    restaurant: Restaurant.dummy(), // Menggunakan dummy restaurant
  );
}
  factory Item.fromJson(Map<String, dynamic> json) {
      print("DEBUG restaurant_id value: ${json['restaurant_id']}");

    return Item(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rate: json['rate']?.toString() ?? '0.0',
      rating: json['rating'] ?? 0,
      type: json['type'] ?? '',
      price: json['price']?.toString(),
      itemCategoryId: json['item_category_id'] ?? 0,
         restaurantId: json['restaurant_id'] ??
        (json['restaurant'] != null ? json['restaurant']['id'] : null), // <- FIX DISINI
      restaurant: Restaurant.fromJson(json['restaurant'] ?? {}),
       itemCategory: json['item_category'] != null
          ? ItemCategory.fromJson(json['item_category'])
          : null,
      categoryName: json['category_name'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'rate': rate,
        'rating': rating,
        'type': type,
        'price': price,
        'item_category_id': itemCategoryId,
        'restaurant_id': restaurantId,
      };

  String get imageUrl => '$baseUrl$image';
}

class ItemCategory {
  final int id;
  final String name;
  final String image;
  final int? itemsCount;

  ItemCategory({
    required this.id,
    required this.name,
    required this.image,
     this.itemsCount,
  });

  factory ItemCategory.dummy() {
  return ItemCategory(
    id: 0,
    name: 'Category',
    image: '', 
  );
}

  factory ItemCategory.fromJson(Map<String, dynamic> json) => ItemCategory(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        itemsCount: json['items_count'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'items_count': itemsCount,
      };

  String get imageUrl => '$baseUrl$image';
}
