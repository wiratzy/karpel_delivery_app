import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kons2/models/order_model.dart';
import 'package:kons2/providers/customer_order_provider.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/view/more/my_orders_view.dart';
import 'package:provider/provider.dart';

// ... import tetap sama

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
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      final data = await context
          .read<CustomerOrderProvider>()
          .fetchOrderById(token, widget.orderId);
      setState(() {
        order = data;
        timeoutTime = order!.orderTimeoutAt!.toLocal();
        remainingTime = timeoutTime!.difference(DateTime.now());
        startCountdown();
        isLoading = false;
      });
    }
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

  Future<void> _updateOrderStatus(String newStatus) async {
    final token = context.read<AuthProvider>().token;
    if (token != null && order != null) {
      try {
        await context
            .read<CustomerOrderProvider>()
            .updateOrderStatus(token, order!.id, newStatus);
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
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
              ? const Center(child: Text("Data tidak ditemukan"))
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            if (order!.status == 'berhasil')
                              const Icon(Icons.check_circle,
                                  color: Colors.green)
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status: ${order!.status.toUpperCase()}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            if (order!.status == 'diantar')
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus('berhasil'),
                                child: const Text("Selesaikan"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (order!.status == 'menunggu_konfirmasi') ...[
                          const Divider(),
                          const Text("Batas waktu konfirmasi:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat('dd MMM yyyy HH:mm:ss')
                              .format(timeoutTime!)),
                          const SizedBox(height: 4),
                          Text(
                            "Sisa waktu: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const Divider(),
                        const Text("Item yang dipesan:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...order!.items.map((item) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Image.network(item.item.image,
                                width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(item.item.name),
                            subtitle: Text(
                                "${item.quantity} x ${currency.format(item.price)}"),
                          );
                        }),
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
                        if ((order!.status == 'diantar' ||
                                order!.status == 'berhasil') &&
                            order!.driver != null) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Driver"),
                            subtitle: Text(
                                "${order!.driver!.name} • ${order!.driver!.phone}"),
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Subtotal"),
                            Text(currency.format(
                                order!.totalPrice - order!.deliveryFee)),
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
                            const Text("Total",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(currency.format(order!.totalPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
