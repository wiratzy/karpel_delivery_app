class RestoFoodModel {
  final String name;
  final String imageUrl;
  final double rate;
  final int ratingCount; // Sebelumnya 'rating' di database
  final String type;
  final double price;

  const RestoFoodModel({
    required this.name,
    required this.imageUrl,
    required this.rate,
    required this.ratingCount,
    required this.type,
    required this.price,
  });
}