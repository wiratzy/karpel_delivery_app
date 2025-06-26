import 'package:kons2/models/home_model.dart';

class CartItem {
  final int id;
  final int userId;
  final int itemId;
  final int quantity;
  final String price;
  final Item item;

  CartItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.item,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        userId: json['user_id'],
        itemId: json['item_id'],
        quantity: json['quantity'],
        price: json['price'].toString(),
        item: Item.fromJson(json['item']),
      );
}
