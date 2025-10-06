class Review {
  final String customerName;
  final String? customerPhoto;
  final String reviewText;
  final int restaurantRating;
  final String createdAt;

  Review({
    required this.customerName,
    this.customerPhoto,
    required this.reviewText,
    required this.restaurantRating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      customerName: json['customer_name'] ?? 'Anonim',
      customerPhoto: json['customer_photo'],
      reviewText: json['review_text'] ?? '',
      restaurantRating: json['restaurant_rating'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
