import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karpel_food_delivery/cofing.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/order_model.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/customer_order_provider.dart';
import 'package:karpel_food_delivery/view/more/customer_detail_view.dart';
import 'package:provider/provider.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView>
    with TickerProviderStateMixin {
  TabController? _tabController;

  final List<String> _tabs = [
    "Semua",
    "Diproses",
    "Diantar",
    "Selesai",
    "Batal"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider =
        Provider.of<CustomerOrderProvider>(context, listen: false);
    if (authProvider.token != null) {
      await orderProvider.fetchMyOrders(authProvider.token!);
    }
  }

  List<Order> _getFilteredOrders(List<Order> allOrders, String status) {
    if (status == "Semua") {
      return allOrders;
    }
    Map<String, List<String>> statusMapping = {
      "Diproses": ['menunggu_konfirmasi', 'diproses'],
      "Diantar": ['diantar'],
      "Selesai": ['berhasil'],
      "Batal": ['dibatalkan'],
    };
    return allOrders
        .where((order) => statusMapping[status]!.contains(order.status))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Saya"),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController!,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
          isScrollable: true,
          indicatorColor: Colors.white,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: Consumer<CustomerOrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController!,
            children: _tabs.map((tabName) {
              final filteredOrders =
                  _getFilteredOrders(orderProvider.orders, tabName);
              return _buildOrderList(filteredOrders);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text("Tidak ada pesanan dalam kategori ini."),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, index);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
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
            builder: (_) => CustomerDetailView(
                orderId: order.id, orderSequence: index + 1)),
      ).then((_) => _loadOrders());
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Pesanan #${order.id}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                order.status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        itemPreview.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Price dibawah name
                      Text(
                        formatPrice(itemPreview.price) + " x ${order.items.length}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            "Total: ${formatPrice(order.totalPrice.toString())}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Tanggal: $formattedDate",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
