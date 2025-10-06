import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/models/order_model.dart';
import 'package:karpel_food_delivery/providers/customer_order_provider.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';

class CustomerDetailView extends StatefulWidget {
  final int orderId;
  final int orderSequence;

  const CustomerDetailView(
      {super.key, required this.orderId, required this.orderSequence});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  Order? _order;
  bool _isLoading = true;
  String? _error;

  DateTime? _timeoutTime;
  Duration _remainingTime = Duration.zero;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await StorageService().getToken();
      if (token == null) throw Exception("Token tidak ditemukan.");

      final data = await context
          .read<CustomerOrderProvider>()
          .fetchOrderById(token, widget.orderId);

      if (!mounted) return;
      setState(() {
        _order = data;
        if (_order?.orderTimeoutAt != null) {
          _timeoutTime = _order!.orderTimeoutAt!.toLocal();
          _startCountdown();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail pesanan.';
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _timeoutTime == null) {
        _countdownTimer?.cancel();
        return;
      }
      final now = DateTime.now();
      final diff = _timeoutTime!.difference(now);
      setState(() {
        _remainingTime = diff.isNegative ? Duration.zero : diff;
      });
      if (diff.isNegative) {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> _updateOrderStatus(String newStatus,
      {int? restoRating, int? itemRating, String? reviewText}) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || _order == null) return;

    try {
      await context.read<CustomerOrderProvider>().updateOrderStatus(
            token,
            _order!.id,
            newStatus,
            restaurantRating: restoRating,
            itemRating: itemRating,
            reviewText: reviewText,
          );
      if (mounted) {
        setState(() => _order = _order!.copyWith(status: newStatus));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan telah diselesaikan!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui status: $e")),
        );
      }
    }
  }

  Future<void> _handleCompleteOrder() async {
    final result = await _showRatingDialog(context);
    if (result != null && mounted) {
      await _updateOrderStatus(
        'berhasil',
        restoRating: result['restaurant_rating'],
        itemRating: result['item_rating'],
        reviewText: result['review_text'], // 👉 kirim komentar
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Memecah UI menjadi beberapa method agar lebih rapi dan elegan
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Tcolor.primary,
        foregroundColor: Tcolor.white,
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _order == null) {
      return _buildErrorView();
    }

    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(_order!),
          if (_order!.status == 'menunggu_konfirmasi') ...[
            const SizedBox(height: 16),
            _buildCountdownCard(),
          ],
          const SizedBox(height: 16),
          _buildRestaurantInfoCard(_order!, currency),
          const SizedBox(height: 16),
          _buildOrderItemsCard(_order!, currency),
          const SizedBox(height: 16),
          _buildDeliveryDetailsCard(_order!),
          const SizedBox(height: 16),
          _buildPricingSummaryCard(_order!, currency),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Order order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pesanan Ke-: ${widget.orderSequence}",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              // Gunakan CrossAxisAlignment.center agar chip dan tombol sejajar vertikal
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PERBAIKAN 1: Bungkus bagian kiri (status) dengan Expanded
                // Ini akan mengambil semua ruang yang tersisa setelah tombol ditempatkan.
                Expanded(
                  child: Row(
                    children: [
                      Text("Status: ",
                          style: Theme.of(context).textTheme.titleSmall),
                      // PERBAIKAN 2: Bungkus Chip dengan Flexible
                      // Ini memungkinkan Chip untuk mengecil jika perlu, mencegah overflow.
                      Flexible(
                        child: Chip(
                          label: Text(
                            order.status.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow
                                .ellipsis, // Tambahkan ini agar teks tidak terpotong kasar
                          ),
                          backgroundColor: _getStatusColor(order.status),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          // Mengurangi padding internal default dari Chip
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer tidak lagi diperlukan karena Expanded sudah mengatur ruang.

                // Tombol akan ditempatkan terlebih dahulu, lalu sisa ruangnya untuk status.
                if (order.status == 'diantar')
                  ElevatedButton.icon(
                    onPressed: _handleCompleteOrder,
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text("Selesaikan"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8) // Atur padding tombol
                        ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, color: Tcolor.primary, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Batas Waktu Konfirmasi",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('dd MMM yyyy, HH:mm:ss').format(_timeoutTime!)),
                const SizedBox(height: 4),
                Text(
                  "Sisa Waktu: ${_remainingTime.inMinutes.toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: TextStyle(
                      color: Tcolor.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfoCard(Order order, NumberFormat currency) {
    final restaurant = order.items.first.item.restaurant;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dari Restoran",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  restaurant.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.restaurant, size: 40),
                ),
              ),
              title: Text(restaurant.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(restaurant.location!,
                  style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(Order order, NumberFormat currency) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Item Dipesan",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.item.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.fastfood, size: 40),
                      ),
                    ),
                    title: Text(item.item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${item.quantity} x ${currency.format(item.price)}"),
                    trailing: Text(currency.format(item.quantity * item.price),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetailsCard(Order order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Detail Pengiriman",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined, color: Tcolor.primary),
              title: const Text("Alamat Pengiriman"),
              subtitle: Text(order.address),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payment_outlined, color: Tcolor.primary),
              title: const Text("Metode Pembayaran"),
              subtitle:
                  Text(order.paymentMethod.replaceAll('_', ' ').toUpperCase()),
            ),
            if (order.driver != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.delivery_dining_outlined, color: Tcolor.primary),
                title: const Text("Driver"),
                subtitle:
                    Text("${order.driver!.name} • ${order.driver!.phone}"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummaryCard(Order order, NumberFormat currency) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPriceRow("Subtotal",
                currency.format(order.totalPrice - order.deliveryFee)),
            const SizedBox(height: 8),
            _buildPriceRow("Ongkos Kirim", currency.format(order.deliveryFee)),
            const Divider(height: 24),
            _buildPriceRow(
              "Total",
              currency.format(order.totalPrice),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    final style = isTotal
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Colors.grey.shade400, size: 80),
            const SizedBox(height: 20),
            Text(
              _error ?? "Terjadi kesalahan",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              "Mohon periksa koneksi internet Anda dan coba lagi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk warna status
  Color _getStatusColor(String status) {
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

  // Dialog rating baru yang lebih elegan dengan bintang
  Future<Map<String, dynamic>?> _showRatingDialog(BuildContext context) async {
    double restoRating = 3.0;
    double itemRating = 3.0;
    final TextEditingController reviewController = TextEditingController();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Ulasan Anda'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Rating Restoran: ${restoRating.toInt()}"),
                  Slider(
                    value: restoRating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) => setDialogState(() => restoRating = val),
                  ),
                  Text("Rating Makanan: ${itemRating.toInt()}"),
                  Slider(
                    value: itemRating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) => setDialogState(() => itemRating = val),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Berikan Ulasan Terbaik...",
                      border: OutlineInputBorder(),
                    ),
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
                    'restaurant_rating': restoRating.toInt(),
                    'item_rating': itemRating.toInt(),
                    'review_text': reviewController.text, // string aman 👍
                  }),
                  child: const Text('Kirim Ulasan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
