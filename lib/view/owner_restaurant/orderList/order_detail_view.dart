import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailView extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailView({super.key, required this.order});

  String _formatStatus(String status) {
    switch (status) {
      case "pending_confirmation":
        return "Menunggu Konfirmasi";
      case "waiting_driver":
        return "Menunggu Driver";
      case "in_progress":
        return "Sedang Dikirim";
      case "delivered":
        return "Selesai";
      default:
        return "Dibatalkan";
    }
  }


void _openWhatsApp(BuildContext context) async {
  final message = Uri.encodeComponent("""
📦 *Detail Pesanan*:
👤 Customer: Adit Pratama
📍 Alamat: Jalan Mawar No. 23
📅 Tanggal: 2025-06-20 09:15
💵 Total: Rp 68.000
📝 Status: Menunggu Konfirmasi
""");

  final url = 'https://wa.me/6281234567890?text=$message';

  final canLaunch = await canLaunchUrlString(url);
  print("Can launch WhatsApp: $canLaunch");

  if (canLaunch) {
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("WhatsApp tidak tersedia di perangkat ini")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Customer: ${order['customer']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("📍 Alamat: ${order['address']}"),
            const SizedBox(height: 8),
            Text("📅 Tanggal: ${order['created_at']}"),
            const SizedBox(height: 8),
            Text("💵 Total: Rp ${order['total']}"),
            const SizedBox(height: 8),
            Text("📝 Status: ${_formatStatus(order['status'])}"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWhatsApp(context),
        icon: const Icon(Icons.telegram),
        label: const Text("Kirim WA"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
