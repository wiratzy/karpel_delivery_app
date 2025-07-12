import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/driver_model.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/driver_provider.dart';
import 'package:provider/provider.dart';

// FUNGSI UTAMA (SEKARANG JAUH LEBIH SEDERHANA)
Future<void> showChooseDriverModal(
  BuildContext context,
  Function(Driver) onDriverSelected,
) async {
  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  if (!context.mounted) return;

  try {
    // Tampilkan loading indicator di sini jika mau
    await driverProvider.fetchDrivers(authProvider.token!);
  } catch (e) {
    if (!context.mounted) return;
    // Tidak perlu pop karena bottom sheet belum ditampilkan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengambil daftar driver')),
    );
    return;
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      // Sekarang kita hanya memanggil widget baru yang sudah stateful
      return _DriverSelectionSheet(
        drivers: driverProvider.drivers,
        isLoading: driverProvider.isLoading,
        onDriverSelected: onDriverSelected,
      );
    },
  );
}


class _DriverSelectionSheet extends StatefulWidget {
  final List<Driver> drivers;
  final bool isLoading;
  final Function(Driver) onDriverSelected;

  const _DriverSelectionSheet({
    required this.drivers,
    required this.isLoading,
    required this.onDriverSelected,
  });

  @override
  State<_DriverSelectionSheet> createState() => _DriverSelectionSheetState();
}

class _DriverSelectionSheetState extends State<_DriverSelectionSheet> {
  String _searchQuery = '';
  List<Driver> _filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar driver saat widget pertama kali dibuat
    _filteredDrivers = widget.drivers;
  }

  // Fungsi pencarian sekarang ada di sini
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDrivers = widget.drivers
          .where((driver) =>
              driver.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari driver...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _handleSearch, // Panggil fungsi search di sini
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: _filteredDrivers.isEmpty
                  ? const Center(child: Text("Driver tidak ditemukan"))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredDrivers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final driver = _filteredDrivers[index];
                        return ListTile(
                          title: Text(driver.name),
                          subtitle: Text(driver.vehicleNumber ?? '-'),
                          trailing: Text(driver.phone ?? '-'),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onDriverSelected(driver);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}