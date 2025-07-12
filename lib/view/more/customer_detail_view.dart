import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/models/order_model.dart';
import 'package:karpel_food_delivery/providers/customer_order_provider.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:karpel_food_delivery/view/more/my_orders_view.dart';

class CustomerDetailView extends StatefulWidget {
  final int orderId;
  const CustomerDetailView({super.key, required this.orderId});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  Order? order;
  bool isLoading = true;

  DateTime? timeoutTime;
  Duration remainingTime = Duration.zero;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final token = await StorageService().getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan.")),
      );
      return;
    }

    try {
      final data = await context
          .read<CustomerOrderProvider>()
          .fetchOrderById(token, widget.orderId);
      setState(() {
        order = data;
        timeoutTime = order!.orderTimeoutAt?.toLocal();
        remainingTime = timeoutTime?.difference(DateTime.now()) ?? Duration.zero;
        startCountdown();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        order = null;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail pesanan.')),
      );
    }
  }

  Future<Map<String, int>?> showRatingDialog(BuildContext context) async {
    double? restoRating = 1;
    double? itemRating = 1;

    return await showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Beri Rating'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rating untuk Restoran:'),
                Slider(
                  value: restoRating ?? 1,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '${restoRating?.toStringAsFixed(0)}',
                  onChanged: (value) => setState(() => restoRating = value),
                ),
                const SizedBox(height: 12),
                const Text('Rating untuk Makanan:'),
                Slider(
                  value: itemRating ?? 1,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '${itemRating?.toStringAsFixed(0)}',
                  onChanged: (value) => setState(() => itemRating = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, {
                  'restaurant_rating': restoRating!.toInt(),
                  'item_rating': itemRating!.toInt(),
                }),
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        remainingTime = timeoutTime!.difference(now);
        if (remainingTime.isNegative) {
          countdownTimer?.cancel();
          remainingTime = Duration.zero;
        }
      });
    });
  }

  Future<void> _updateOrderStatus(String newStatus, {int? restoRating, int? itemRating}) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || order == null) return;

    try {
      await context.read<CustomerOrderProvider>().updateOrderStatus(
        token,
        order!.id,
        newStatus,
        restaurantRating: restoRating,
        itemRating: itemRating,
      );

      setState(() {
        order = order!.copyWith(status: newStatus);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesanan telah diselesaikan!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui status: $e")),
      );
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, MyOrdersView());
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      const Text("Gagal memuat data pesanan",
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadDetail,
                        child: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ID Pesanan: #${order!.id}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (order!.status == 'berhasil')
                              const Icon(Icons.check_circle, color: Colors.green)
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status: ${order!.status.toUpperCase()}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (order!.status == 'diantar')
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await showRatingDialog(context);
                                  if (result != null) {
                                    await _updateOrderStatus('berhasil',
                                      restoRating: result['restaurant_rating'],
                                      itemRating: result['item_rating']
                                    );
                                  }
                                },
                                child: const Text("Selesaikan"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (order!.status == 'menunggu_konfirmasi') ...[
                          const Divider(),
                          const Text("Batas waktu konfirmasi:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat('dd MMM yyyy HH:mm:ss').format(timeoutTime!)),
                          const SizedBox(height: 4),
                          Text(
                            "Sisa waktu: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                            style:
                                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const Divider(),
                        const Text("Item yang dipesan:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...order!.items.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Image.network(
                                item.item.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(item.item.name),
                              subtitle: Text(
                                  "${item.quantity} x ${currency.format(item.price)}"),
                            )),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Alamat Pengiriman"),
                          subtitle: Text(order!.address),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Metode Pembayaran"),
                          subtitle: Text(order!.paymentMethod),
                        ),
                        const Divider(),
                        if ((order!.status == 'diantar' || order!.status == 'berhasil') &&
                            order!.driver != null) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Driver"),
                            subtitle:
                                Text("${order!.driver!.name} • ${order!.driver!.phone}"),
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Subtotal"),
                            Text(currency.format(order!.totalPrice - order!.deliveryFee)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Delivery Fee"),
                            Text(currency.format(order!.deliveryFee)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(currency.format(order!.totalPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
