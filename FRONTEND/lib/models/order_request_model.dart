class OrderRequest {
  final String paymentMethod;
  final String address;
  final double latitude;
  final double longitude;
  final List<OrderItemData> items;
  final double subtotal;
  final double deliveryFee;
  final int restaurantId;

  OrderRequest({
    required this.paymentMethod,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.restaurantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'restaurant_id': restaurantId,
    };
  }
}

class OrderItemData {
  final int itemId;
  final int quantity;

  OrderItemData({
    required this.itemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity,
    };
  }
}
