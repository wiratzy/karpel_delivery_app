import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/restaurant_aplication.dart';
import 'package:karpel_food_delivery/providers/AdminRestaurantApplicationProvider.dart';

// 1. Ubah menjadi StatefulWidget
class AdminRestaurantApplicationDetailView extends StatefulWidget {
  final RestaurantApplication application;

  const AdminRestaurantApplicationDetailView({super.key, required this.application});

  @override
  State<AdminRestaurantApplicationDetailView> createState() =>
      _AdminRestaurantApplicationDetailViewState();
}

class _AdminRestaurantApplicationDetailViewState
    extends State<AdminRestaurantApplicationDetailView> {
  // 2. Tambahkan state untuk melacak status loading
  bool _isLoading = false;

  // Method untuk menangani update status (terima/tolak)
  Future<void> _handleUpdateStatus(
      BuildContext context, String status) async {
    final provider =
        Provider.of<AdminRestaurantApplicationProvider>(context, listen: false);
    final action = status == 'approved' ? 'menerima' : 'menolak';

    final confirm = await _showConfirmationDialog(context, action);
    if (confirm != true) return;

    // 3. Mulai loading
    if (mounted) setState(() => _isLoading = true);

    try {
      final success = status == 'approved'
          ? await provider.confirmApplication(widget.application.id)
          : await provider.rejectApplication(widget.application.id);

      if (mounted) {
        if (success) {
          _showSnackBar(context, "Pengajuan berhasil di$action!");
          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        } else {
          _showSnackBar(context, "Gagal $action pengajuan.", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, "Error: ${e.toString()}", isError: true);
      }
    } finally {
      // 4. Hentikan loading, apapun hasilnya
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pengajuan Restoran"),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar Restoran
            Center(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.application.image ??
                        'https://placehold.co/400x200/cccccc/333333?text=No+Image',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image,
                          size: 70, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Bagian Informasi Restoran
            _buildSectionTitle("Informasi Restoran"),
            const Divider(height: 20, thickness: 1),
            _buildDetailRow("Nama Restoran", widget.application.name),
            _buildDetailRow("Alamat", widget.application.location),
            _buildDetailRow("Email", widget.application.email),
            _buildDetailRow(
                "Telepon", widget.application.phone ?? "Tidak ada"),
            _buildDetailRow(
                "Tipe Restoran", widget.application.type ?? "Tidak ada"),
            _buildDetailRow(
                "Jenis Makanan", widget.application.foodType ?? "Tidak ada"),

            const SizedBox(height: 25),

            // Bagian Status
            _buildSectionTitle("Status Pengajuan"),
            const Divider(height: 20, thickness: 1),
            Row(
              children: [
                const Text(
                  "Status:",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    _formatStatus(widget.application.status ?? ""),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor:
                      _getStatusColor(widget.application.status ?? ""),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Bagian Tombol Aksi
            if (widget.application.status == 'pending')
              Center(
                child: Column(
                  children: [
                    _buildActionButton(
                      context: context,
                      label: "Terima",
                      icon: Icons.check,
                      color: Colors.green,
                      onPressed: () => _handleUpdateStatus(context, 'approved'),
                    ),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      context: context,
                      label: "Tolak",
                      icon: Icons.close,
                      color: Colors.red,
                      onPressed: () => _handleUpdateStatus(context, 'rejected'),
                    ),
                  ],
                ),
              ),
            if (widget.application.status != 'pending')
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Pengajuan ini sudah ${_formatStatus(widget.application.status ?? '').toLowerCase()}.",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PEMBANTU ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Tcolor.primary,
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      // 5. Tombol akan nonaktif jika _isLoading true
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, color: Colors.white),
      label: _isLoading
          // 6. Tampilkan loading indicator jika sedang loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(200, 50), // Atur ukuran tombol
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String action) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi $action"),
          content: Text(
              "Apakah Anda yakin ingin $action pengajuan restoran ${widget.application.name}?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(action == "menerima" ? "Ya, Terima" : "Ya, Tolak"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.amber.shade700;
      case "approved":
        return Colors.green.shade700;
      case "rejected":
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case "pending":
        return "Menunggu";
      case "approved":
        return "Diterima";
      case "rejected":
        return "Ditolak";
      default:
        return "Tidak Diketahui";
    }
  }
}