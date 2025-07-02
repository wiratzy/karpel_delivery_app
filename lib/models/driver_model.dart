class Driver {
  final int id;
  final String name;
  final String? photo;
  final String? phone;
  final String? address;
    final String? vehicleNumber; // ✅ Tambahkan ini jika perlu


  Driver({
    required this.id,
    required this.name,
    this.photo,
    this.phone,
    this.address,
        this.vehicleNumber, // ✅ Pastikan ada di constructor

  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      photo: json['photo'], // jangan pakai .toString() atau !
      phone: json['phone'],
      address: json['address'],
            vehicleNumber: json['vehicle_number'], // ✅ Parsing data dari API

    );
  }
}
