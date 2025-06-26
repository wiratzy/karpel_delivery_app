import 'package:flutter/material.dart';
import 'package:kons2/view/owner_restaurant/orderList/order_detail_view.dart';

class RestoOrderListView extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {
      "customer": "Adit Pratama",
      "address": "Jalan Mawar No. 23",
      "created_at": "2025-06-20 09:15",
      "status": "pending_confirmation",
      "total": 68000,
    },
    {
      "customer": "Lina Marlina",
      "address": "Jalan Kenanga No. 12",
      "created_at": "2025-06-20 09:50",
      "status": "waiting_driver",
      "total": 45000,
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case "pending_confirmation":
        return Colors.orange;
      case "waiting_driver":
        return Colors.blue;
      case "in_progress":
        return Colors.green;
      case "delivered":
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Masuk", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kiri: Informasi pesanan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['customer'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("Alamat: ${order['address']}"),
                        Text("Tanggal: ${order['created_at']}"),
                        const SizedBox(height: 8),
                        Text(
                          _formatStatus(order['status']),
                          style: TextStyle(
                            color: _statusColor(order['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Kanan: Total + tombol
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${order['total']}",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailView(order: order),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Icon(Icons.remove_red_eye, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
