import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/models/order_request_model.dart';
import 'package:kons2/providers/item_provider.dart';
import 'package:kons2/providers/order_provider.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/view/more/customer_detail_view.dart';
import 'package:kons2/view/more/my_order_view.dart';
import 'package:kons2/view/more/my_orders_view.dart';
import 'package:kons2/view/more/pick_location_view.dart';
import 'package:provider/provider.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int selectMethod = 0;
  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/img/cash.png"},
  ];

  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (user != null) {
      _selectedAddress = user.address;
      _latitude = user.latitude;
      _longitude = user.longitude;
    }
    print(user);
    print("🧭 Loaded user address: $_selectedAddress");
    print("🧭 Loaded lat: $_latitude, long: $_longitude");
  }

  Future<void> _pickNewAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PickLocationView()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedAddress = result['formatted_address'];
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatter untuk harga Rupiah
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

// Ambil cart
    final cartItems = Provider.of<ItemProvider>(context).cartItems;

// Hitung sub total
    final int subtotal = cartItems.fold(0, (sum, item) {
      final price = double.tryParse(item.price)?.round() ?? 0;
      return sum + (price * item.quantity);
    });

// Delivery fee dari restaurant pertama (karena dalam 1 order semua dari 1 resto)
    final int deliveryFee = cartItems.isNotEmpty
        ? cartItems.first.item.restaurant.deliveryFee.toInt()
        : 0;

// Diskon (jika ada logic, sementara 0)

// Total
    final int total = subtotal + deliveryFee;
    return Scaffold(
      backgroundColor: Tcolor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                          color: Tcolor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== ALAMAT =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Delivery Address",
                        style: TextStyle(
                            color: Tcolor.secondaryText, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedAddress ?? 'Alamat belum dipilih',
                            style: TextStyle(
                              color: Tcolor.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: _pickNewAddress,
                          child: Text("Change",
                              style: TextStyle(
                                  color: Tcolor.primary,
                                  fontWeight: FontWeight.w700)),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(height: 8, color: Tcolor.textfield),

              // ===== PEMBAYARAN =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text("Payment method",
                        style: TextStyle(
                            color: Tcolor.secondaryText, fontSize: 13)),
                    ListView.builder(
                      itemCount: paymentArr.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var p = paymentArr[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Tcolor.textfield,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Tcolor.secondaryText.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(p['icon'], width: 50, height: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(p['name'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() => selectMethod = index);
                                },
                                child: Icon(
                                  selectMethod == index
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: Tcolor.primary,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(height: 8, color: Tcolor.textfield),

              // Widget Ringkasan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    _buildPriceRow(
                        "Sub Total", currencyFormat.format(subtotal)),
                    _buildPriceRow(
                        "Delivery Cost", currencyFormat.format(deliveryFee)),
                    const Divider(),
                    _buildPriceRow("Total", currencyFormat.format(total),
                        isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(height: 8, color: Tcolor.textfield),

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: RoundButton(
                  title: "Send Order",
                  onPressed: () async {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    final orderProvider =
                        Provider.of<OrderProvider>(context, listen: false);
                    final cartProvider =
                        Provider.of<ItemProvider>(context, listen: false);

                    final token = authProvider.token;
                    final cartItems = cartProvider.cartItems;

                    if (token == null || cartItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Keranjang kosong atau belum login.")),
                      );
                      return;
                    }

                    if (_selectedAddress == null ||
                        _latitude == null ||
                        _longitude == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Alamat pengiriman belum lengkap.")),
                      );
                      return;
                    }

                    final deliveryFee =
                        cartItems.first.item.restaurant.deliveryFee ?? 0;

                    final orderRequest = OrderRequest(
                      paymentMethod: paymentArr[selectMethod]['name'],
                      address: _selectedAddress!,
                      latitude: _latitude!,
                      longitude: _longitude!,
                      items: cartItems
                          .map((item) => OrderItemData(
                                itemId: item.item.id,
                                quantity: item.quantity,
                              ))
                          .toList(),
                      subtotal: cartItems.fold(
                        0,
                        (sum, item) =>
                            sum +
                            ((double.tryParse(item.price)?.round() ?? 0) *
                                item.quantity),
                      ),
                      deliveryFee: deliveryFee,
                      restaurantId: cartItems.first.item.restaurant.id,
                    );

                    try {
                      final result = await orderProvider.checkoutOrder(
                          token, orderRequest);

                      cartProvider.clearCart(token);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Pesanan berhasil dibuat! ID: ${result['order_id']}")),
                      );

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) =>  CustomerDetailView(orderId: result['order_id'],)),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Checkout gagal: $e")),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
