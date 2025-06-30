import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/models/order_model.dart';
import 'package:kons2/providers/order_provider.dart';
import 'package:kons2/providers/auth_provider.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;

  const OrderDetailView({super.key, required this.orderId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  Order? _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    setState(() => _isLoading = true);
    try {
      final fetchedOrder =
          await orderProvider.refreshOrderById(token, widget.orderId);
      setState(() => _order = fetchedOrder);
    } catch (e) {
      debugPrint('Gagal mengambil detail order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memuat pesanan.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null || _order == null) return;

    setState(() => _isLoading = true);
    try {
      await orderProvider.updateOrderStatus(token, widget.orderId, newStatus);
      await _loadOrder(); // Refresh data setelah update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
      ),
      body: _order == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrder,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('Informasi Pemesan'),
                  _buildInfoTile('Nama', _order!.user!.name),
                  _buildInfoTile('Alamat', _order!.address),
                  _buildInfoTile('No WA/Telephone', _order!.user!.phone),
                  _buildInfoTile('Metode Pembayaran', _order!.paymentMethod),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Status Pesanan'),
                  _buildStatusChip(_order!.status),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Item Dipesan'),
                  ..._order!.items.map(_buildItemCard),
                  const Divider(height: 32),
                  _buildSectionTitle('Ringkasan'),
                  _buildPriceRow(
                      'Subtotal', currency.format(_calculateSubtotal())),
                  _buildPriceRow(
                      'Ongkir', currency.format(_order!.deliveryFee)),
                  _buildPriceRow('Total', currency.format(_order!.totalPrice),
                      isBold: true),
                  const SizedBox(height: 24),
                  if (_order!.status == 'menunggu_konfirmasi')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _updateStatus('diproses'),
                          icon: const Icon(Icons.check),
                          label: const Text('Konfirmasi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _updateStatus('dibatalkan'),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Tolak'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  else if (_order!.status == 'diproses')
                    Center(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoading ? null : () => _updateStatus('diantar'),
                        icon: const Icon(Icons.delivery_dining),
                        label: const Text('Tandai Diantar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );

  Widget _buildInfoTile(String label, String value) => ListTile(
        dense: true,
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(value),
      );

  Widget _buildStatusChip(String status) {
    final Map<String, Color> statusColors = {
      'menunggu_konfirmasi': Colors.orange,
      'diproses': Colors.blue,
      'diantar': Colors.green,
      'dibatalkan': Colors.red,
      'berhasil': Colors.teal,
    };

    return Chip(
      label: Text(status.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(color: Colors.white)),
      backgroundColor: statusColors[status] ?? Colors.grey,
    );
  }

  Widget _buildItemCard(OrderItemModel item) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.item.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(item.item.name),
        subtitle: Text('${item.quantity} x ${currency.format(item.price)}'),
        trailing: Text(
          currency.format(item.quantity * item.price),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return _order!.items
        .fold(0, (sum, item) => sum + (item.quantity * item.price));
  }
}
