import 'package:kons2/models/driver_model.dart';
import 'package:kons2/models/home_model.dart';
import 'package:kons2/models/user_model.dart';

class Order {
  final int id;
   final int? userId;          // <-- DITAMBAHKAN
  final int? restaurantId;    // <-- DITAMBAHKAN
  final int? driverId; 
  final String status;
  final String address;
  final double totalPrice;
  final double deliveryFee;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? orderTimeoutAt;
  final List<OrderItemModel> items;
final User? user;
final Driver? driver;

  Order({
    required this.id,
     this.userId,           // <-- DITAMBAHKAN
    this.restaurantId,     // <-- DITAMBAHKAN
    this.driverId,  
    required this.status,
    required this.address,
    required this.totalPrice,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.createdAt,
    this.orderTimeoutAt,
    required this.items,
    required this.user,
    this.driver,
  });

  Order copyWith({
    String? status,
    String? address,
    double? totalPrice,
    double? deliveryFee,
    String? paymentMethod,
    DateTime? createdAt,
    List<OrderItemModel>? items,
    User? user,
  }) {
    return Order(
      id: id,
      status: status ?? this.status,
      address: address ?? this.address,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      user: user ?? this.user,
    );
  }
  factory Order.fromJson(Map<String, dynamic> json) {
  try {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      driverId: json['driver_id'],
      status: json['status'],
      address: json['address'] ?? '-',
      totalPrice: double.parse(json['total_price'].toString()),
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      paymentMethod: json['payment_method'],
      orderTimeoutAt: json['order_timeout_at'] != null
          ? DateTime.parse(json['order_timeout_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : null,
      driver: json['driver'] != null
          ? Driver.fromJson(json['driver'])
          : null,
    );
  } catch (e, st) {
    print('❌ Error parsing Order.fromJson: $e');
    print('Stack trace: $st');
    rethrow;
  }
}

}

class OrderItemModel {
  final int quantity;
  final double price;
  final Item item;

  OrderItemModel({
    required this.quantity,
    required this.price,
    required this.item,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
      print('DEBUG ITEM JSON: ${json['item']}');

    return OrderItemModel(
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      item: Item.fromJson(json['item']),
    );
  }
}
