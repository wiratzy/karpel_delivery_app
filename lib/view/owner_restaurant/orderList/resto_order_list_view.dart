import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart'; // Asumsi Anda punya file ini untuk warna
import 'package:kons2/models/order_model.dart'; // Pastikan path ini benar
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/providers/order_provider.dart';
import 'package:kons2/view/owner_restaurant/orderList/order_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang

class RestoOrderListView extends StatefulWidget {
  const RestoOrderListView({super.key});

  @override
  State<RestoOrderListView> createState() => _RestoOrderListViewState();
}

class _RestoOrderListViewState extends State<RestoOrderListView> {
  @override
  void initState() {
    super.initState();
    // CARA YANG BENAR: Panggil fetch data setelah frame pertama selesai di-build.
    // Ini memastikan context sudah sepenuhnya tersedia dan aman untuk digunakan.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  /// Fungsi terpusat untuk mengambil data pesanan.
  /// Bisa dipanggil dari initState atau RefreshIndicator.
  Future<void> _fetchOrders() async {
  if (mounted) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await orderProvider.fetchRestaurantOrders(token); // ✅ Kirim token
    } else {
      print('Token tidak tersedia');
    }
  }
}


  /// Helper untuk mendapatkan warna berdasarkan status pesanan
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu_konfirmasi':
        return Colors.orange.shade700;
      case 'diproses':
        return Colors.blue.shade700;
      case 'diantar':
        return const Color.fromARGB(255, 168, 53, 145);
      case 'dibatalkan':
        return Colors.red.shade700;
      case 'berhasil':
        return const Color.fromARGB(255, 18, 164, 64);
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendengarkan perubahan dari OrderProvider
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan Restoran'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // --- 1. Loading State ---
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. Error State ---
          if (orderProvider.errorMessage != null && orderProvider.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal Memuat Data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchOrders,
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            );
          }

          // --- 3. Empty State ---
          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum Ada Pesanan Masuk', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          // --- 4. Content State (Data Tersedia) ---
          final orders = orderProvider.orders;
          return RefreshIndicator(
            onRefresh: _fetchOrders, // Tambahkan fitur pull-to-refresh
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order); // Gunakan helper widget
              },
            ),
          );
        },
      ),
    );
  }

  /// Widget helper untuk membangun setiap kartu pesanan agar lebih rapi.
  Widget _buildOrderCard(Order order) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return InkWell(
      onTap: () {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailView(orderId: order.id), // 👈 navigasi ke detail
        ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // Agar border radius diterapkan pada child
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Bagian Header Kartu ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ID Pesanan: #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Flexible(
                    child: Chip(
                      label: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      backgroundColor: _getStatusColor(order.status),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
      
              // --- Detail Pemesan ---
              Text('Pemesan: ${order.user?.name}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 4),
              Text('Metode Bayar: ${order.paymentMethod}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
      
              // --- Daftar Item ---
              const Text(
                'Items Dipesan:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.item.image, // URL gambar dari model
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      // Tambahkan loading dan error builder untuk UX yang lebih baik
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 50, height: 50, color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50, height: 50, color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  title: Text(item.item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${item.quantity} x ${currencyFormatter.format(item.price)}'),
                );
              }).toList(),
              const Divider(height: 20),
      
              // --- Bagian Footer Kartu ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Total Pesanan: ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    currencyFormatter.format(order.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
