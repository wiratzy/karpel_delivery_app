import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/models/order_model.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/providers/customer_order_provider.dart';
import 'package:kons2/view/more/customer_detail_view.dart';
import 'package:provider/provider.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider =
        Provider.of<CustomerOrderProvider>(context, listen: false);
    if (authProvider.token != null) {
      await orderProvider.fetchMyOrders(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerOrderProvider>(
      builder: (context, orderProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Pesanan Saya"),
            backgroundColor: Tcolor.primary,
          ),
          body: orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : orderProvider.orders.isEmpty
                  ? const Center(child: Text("Belum ada pesanan."))
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: orderProvider.orders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.orders[index];
                          return _buildOrderCard(order);
                        },
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    DateTime jakartaTime = order.createdAt.toLocal();
    String formattedDate =
        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(jakartaTime);

    final statusColor = _statusColor(order.status);
    final itemPreview = order.items.isNotEmpty ? order.items.first.item : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CustomerDetailView(orderId: order.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Tcolor.textfield,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Tcolor.primary.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pesanan #${order.id}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Item Preview
            if (itemPreview != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      itemPreview.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tambahkan Expanded di sini
                  Expanded(
                    child: Text(
                      itemPreview.name,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Info Tambahan
            Text("Total: Rp ${order.totalPrice.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.w500)),

            Text(
              "Tanggal: $formattedDate",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'diantar':
        return Colors.purple;
      case 'berhasil':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
