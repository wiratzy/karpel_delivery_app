class Driver {
  final int id;
  final String name;
  final String? phone;
  final String? vehicleNumber; // ✅ Tambahkan ini jika perlu

  Driver({
    required this.id,
    required this.name,
    this.phone,
    this.vehicleNumber, // ✅ Pastikan ada di constructor
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      phone: json['phone'],
      vehicleNumber: json['vehicle_number'], // ✅ Parsing data dari API
    );
  }
}
