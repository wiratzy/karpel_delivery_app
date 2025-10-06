import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/order_model.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/order_provider.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/orderList/order_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RestoOrderListView extends StatefulWidget {
  const RestoOrderListView({super.key});

  @override
  State<RestoOrderListView> createState() => _RestoOrderListViewState();
}

// 1. Tambahkan TickerProviderStateMixin untuk TabController
class _RestoOrderListViewState extends State<RestoOrderListView>
    with TickerProviderStateMixin {
  // 2. Deklarasi controller dan state untuk tab & search
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = [
    "Semua",
    "Masuk",
    "Diproses",
    "Diantar",
    "Selesai",
    "Batal"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (mounted) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token != null) {
        await orderProvider.fetchRestaurantOrders(token);
      } else {
        print('Token tidak tersedia');
      }
    }
  }

  /// 3. Fungsi untuk memfilter berdasarkan status tab DAN query pencarian
  List<Order> _getFilteredAndSearchedOrders(
      List<Order> allOrders, String statusTab) {
    List<Order> filteredByStatus;

    // Filter berdasarkan status dari tab
    if (statusTab == "Semua") {
      filteredByStatus = allOrders;
    } else {
      Map<String, List<String>> statusMapping = {
        "Masuk": ['menunggu_konfirmasi'],
        "Diproses": ['diproses'],
        "Diantar": ['diantar'],
        "Selesai": ['berhasil'],
        "Batal": ['dibatalkan'],
      };
      filteredByStatus = allOrders
          .where((order) => statusMapping[statusTab]!.contains(order.status))
          .toList();
    }

    // Filter berdasarkan query pencarian dari nama pemesan
    if (_searchQuery.isEmpty) {
      return filteredByStatus;
    } else {
      return filteredByStatus.where((order) {
        final userName = order.user?.name.toLowerCase() ?? '';
        return userName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        // 4. Tambahkan TabBar di bawah AppBar
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          unselectedLabelStyle:
              const TextStyle(fontSize: 15, color: Colors.white54),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      // 5. Gunakan Column untuk menampung Search Bar dan TabBarView
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama pemesan...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Daftar Pesanan
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (orderProvider.errorMessage != null &&
                    orderProvider.orders.isEmpty) {
                  return Center(
                      child: Text('Error: ${orderProvider.errorMessage}'));
                }

                // 6. Gunakan TabBarView untuk menampilkan konten sesuai tab
                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tabName) {
                    final filteredOrders = _getFilteredAndSearchedOrders(
                        orderProvider.orders, tabName);
                    return _buildOrderList(filteredOrders);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membangun daftar pesanan (ListView)
  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tidak ada pesanan ditemukan.',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order); // Gunakan helper widget
        },
      ),
    );
  }

  /// Widget helper untuk membangun setiap kartu pesanan
  Widget _buildOrderCard(Order order) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailView(orderId: order.id),
          ),
        ).then((_) => _fetchOrders()); // Refresh data saat kembali dari detail
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ID: #${order.id}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Chip(
                    label: Text(
                      order.status.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(order.status),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                'Pemesan: ${order.user?.name ?? 'Tanpa Nama'}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text('Metode Bayar: ${order.paymentMethod}',
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                'No. Telepon: ${order.user?.phone ?? 'Tidak ada nomor telepon'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items.map((item) {
                  return Text(
                    '${item.quantity} x ${item.item.name}',
                    style: const TextStyle(fontSize: 15),
                  );
                }).toList(),
              ),
             
              const SizedBox(height: 8),
              Image.network(
                order.items.first.item.image ?? '',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 100);
                },
              ),
              const SizedBox(height: 8),

              Text(
                'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt)}',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Total: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    currencyFormatter.format(order.totalPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
