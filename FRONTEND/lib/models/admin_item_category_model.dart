class AdminItemCategory {
  final int id;
  final String name;
  final String? image;

  AdminItemCategory({
    required this.id,
    required this.name,
    this.image,
  });

  factory AdminItemCategory.fromJson(Map<String, dynamic> json) {
    return AdminItemCategory(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}