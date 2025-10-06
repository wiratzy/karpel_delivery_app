import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/models/driver_model.dart';
import 'package:karpel_food_delivery/providers/owner_driver_provider.dart';

class RestoDriverInfoView extends StatefulWidget {
  const RestoDriverInfoView({super.key});

  @override
  State<RestoDriverInfoView> createState() => _RestoDriverInfoViewState();
}

class _RestoDriverInfoViewState extends State<RestoDriverInfoView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OwnerDriverProvider>().init();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _searchController.clear();
    if (mounted) {
      await context.read<OwnerDriverProvider>().fetchDrivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Driver", style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
            color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari driver berdasarkan nama...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<OwnerDriverProvider>().search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              onChanged: (val) => context.read<OwnerDriverProvider>().search(val),
            ),
          ),
          Expanded(
            child: Consumer<OwnerDriverProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final drivers = provider.drivers;

                if (drivers.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: const CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: Center(child: Text("Belum ada driver terdaftar.")),
                        )
                      ],
                    ),
                  );
                }

                // ## PERUBAHAN UTAMA DI SINI ##
                // Mengganti GridView.builder menjadi ListView.builder
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      // Menggunakan Card dengan ListTile agar lebih rapi untuk layout list
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            driver.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Tlp: ${driver.phone ?? "-"}'),
                              Text('Plat: ${driver.vehicleNumber ?? "-"}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // Agar Row tidak makan banyak tempat
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                onPressed: () => _navigateToEdit(driver),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _showDeleteDialog(driver),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Helper methods tetap sama
  void _navigateToCreate() async {
    final result = await Navigator.pushNamed(context, '/createDriver');
    if (result == true && mounted) {
      _refresh();
    }
  }

  void _navigateToEdit(Driver driver) async {
    final result = await Navigator.pushNamed(
      context,
      '/editDriver',
      arguments: driver,
    );
    if (result == true && mounted) {
      _refresh();
    }
  }

  void _showDeleteDialog(Driver driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Driver?'),
        content: Text('Anda yakin ingin menghapus driver "${driver.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (!mounted) return;
              Navigator.pop(context);
              await context.read<OwnerDriverProvider>().deleteDriver(driver.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}