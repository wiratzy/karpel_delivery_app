class CustomerRestaurant {
  final int id;
  final String name;
  final String? image;
  final double? rate;
  final double? rating;
  final String? location;
  final String? type;
  final String? foodType;

  CustomerRestaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.rate,
    this.rating,
    this.location,
    this.type,
    this.foodType,
  });

  factory CustomerRestaurant.dummy() {
  return CustomerRestaurant(
    id: 0,
    name: 'Nama Restoran',
    image: '', // Biarkan kosong
    rate: 4.5,
    rating: 100,
    type: 'Tipe Restoran',
    foodType: 'Jenis Makanan',
    location: 'Lokasi Restoran',
  );
}

  factory CustomerRestaurant.fromJson(Map<String, dynamic> json) {
    return CustomerRestaurant(
      id: json['id'],
      name: json['name'],
      image: json['image'],
           rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      rate: json['rate'] != null
          ? double.tryParse(json['rate'].toString())
          : null,
      location: json['location'],
      type: json['type'],
      foodType: json['food_type'],
    );
  }
}
