class   RestaurantApplication {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String location;
  final String? image;
  final String? status;
  final String? type;
  final String? foodType;

  RestaurantApplication({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.location,
    this.image,
    this.status,
    this.type,
    this.foodType,
  });

  factory RestaurantApplication.fromJson(Map<String, dynamic> json) {
    return RestaurantApplication(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      image: json['image'],
      status: json['status'],
      type: json['type'],
      foodType: json['food_type'],
    );
  }
}
