import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/providers/admin_restaurant_provider.dart';
import 'package:karpel_food_delivery/view/admin/resto/admin_restaurant_form_view.dart';
import 'package:provider/provider.dart';

class AdminRestaurantListView extends StatefulWidget {
  const AdminRestaurantListView({super.key});

  @override
  State<AdminRestaurantListView> createState() =>
      _AdminRestaurantListViewState();
}

class _AdminRestaurantListViewState extends State<AdminRestaurantListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminRestaurantProvider>(context, listen: false).init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminRestaurantProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Tcolor.primary,
            foregroundColor: Colors.white,
            title: const Text("Daftar Restoran"),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminRestaurantFormView(),
                    ),
                  );
                  if (result == true) {
                    provider.fetchRestaurants();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari restoran...",
                    filled: true,
                    fillColor: Tcolor.textfield,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Tcolor.secondaryText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: provider.search,
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator(color: Tcolor.primary))
                    : provider.restaurants.isEmpty
                        ? Center(
                            child: Text(
                              "Tidak ada restoran ditemukan.",
                              style: TextStyle(color: Tcolor.secondaryText, fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => provider.fetchRestaurants(),
                            color: Tcolor.primary,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                // Sesuaikan childAspectRatio lagi untuk memberi lebih banyak ruang vertikal
                                childAspectRatio: 1.2, // Menaikkan sedikit dari 1.15
                              ),
                              itemCount: provider.restaurants.length,
                              itemBuilder: (context, index) {
                                final resto = provider.restaurants[index];
                                return Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Gambar Restoran
                                      Expanded(
                                        flex: 4,
                                        child: (resto.image != null && Uri.tryParse(resto.image!)?.hasAbsolutePath == true)
                                            ? Image.network(
                                                resto.image!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                      alignment: Alignment.center,
                                                      child: Icon(Icons.restaurant_menu, size: 70, color: Colors.grey[400]),
                                                    ),
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                alignment: Alignment.center,
                                                child: Icon(Icons.restaurant_menu, size: 70, color: Colors.grey[400]),
                                              ),
                                      ),
                                      // Detail Teks Restoran
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                resto.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Tcolor.primaryText,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                resto.location ?? 'Alamat tidak tersedia',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Tcolor.secondaryText,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${resto.type ?? '-'} (${resto.foodType ?? '-'})',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              // Rating dan Owner Info
                                              Expanded( // <-- Wrap content with Expanded if it could overflow
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min, // Penting agar tidak mengambil semua ruang
                                                      children: [
                                                        Icon(Icons.star, color: Colors.amber, size: 18),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          resto.rate?.toStringAsFixed(1) ?? 'N/A',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Tcolor.primaryText,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' (${resto.rating ?? 0})',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Tcolor.secondaryText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Informasi Owner
                                                    if (resto.owner != null)
                                                      Expanded( // <-- Expanded agar owner text bisa melipat jika perlu
                                                        child: Tooltip(
                                                          message: 'Owner: ${resto.owner!.name}\nEmail: ${resto.owner!.email}\nPhone: ${resto.owner!.phone ?? '-'}',
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min, // Penting agar tidak mengambil semua ruang
                                                            children: [
                                                              Icon(Icons.person_outline, size: 18, color: Tcolor.secondaryText),
                                                              const SizedBox(width: 4),
                                                              Flexible( // <-- Gunakan Flexible untuk nama owner
                                                                child: Text(
                                                                  resto.owner!.name.split(' ').first,
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Tcolor.secondaryText,
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis, // Elipsis jika terlalu panjang
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Tombol Aksi di bagian bawah Card
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0), // <-- Kurangi padding horizontal dan vertikal
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              // Tombol Edit
                                              SizedBox( // <-- Wrap dengan SizedBox untuk kontrol ukuran
                                                width: 48, // Ukuran sentuh IconButton default sekitar 48
                                                height: 48,
                                                child: IconButton(
                                                  icon: Icon(Icons.edit, size: 22, color: Tcolor.secondaryText),
                                                  onPressed: () async {
                                                    final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => AdminRestaurantFormView(
                                                          restaurant: resto,
                                                        ),
                                                      ),
                                                    );
                                                    if (result == true) {
                                                      provider.fetchRestaurants();
                                                    }
                                                  },
                                                ),
                                              ),
                                              // Tombol Delete
                                              SizedBox( // <-- Wrap dengan SizedBox untuk kontrol ukuran
                                                width: 48,
                                                height: 48,
                                                child: IconButton(
                                                  icon: Icon(Icons.delete, size: 22, color: Colors.red),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (_) => AlertDialog(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                        title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        content: Text('Anda yakin ingin menghapus restoran "${resto.name}"? Tindakan ini tidak dapat dibatalkan.'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () => Navigator.pop(context, false),
                                                              child: Text('Batal', style: TextStyle(color: Tcolor.secondaryText))),
                                                          ElevatedButton(
                                                              onPressed: () => Navigator.pop(context, true),
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                              child: const Text('Hapus')),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await provider.deleteRestaurant(resto.id);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
         
        );
      },
    );
  }
}