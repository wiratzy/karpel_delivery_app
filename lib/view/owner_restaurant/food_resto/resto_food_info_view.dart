import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/cofing.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/food_resto/detail_food_view.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/providers/owner_item_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';

class RestoFoodInfoView extends StatefulWidget {
  const RestoFoodInfoView({super.key});

  @override
  State<RestoFoodInfoView> createState() => _RestoFoodInfoViewState();
}

class _RestoFoodInfoViewState extends State<RestoFoodInfoView> {
  String search = '';
  int? selectedCategoryId;

  List<ItemCategory> categories = [];
  bool isCategoryLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchData();
  }

  Future<void> _fetchCategories() async {
    setState(() => isCategoryLoading = true);
    try {
      final token = await StorageService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final result = await ApiService().fetchItemCategories(token: token);
      setState(() {
        categories = result;
      });
    } catch (e) {
      print('❌ Gagal ambil kategori: $e');
    } finally {
      setState(() => isCategoryLoading = false);
    }
  }

  Future<void> _fetchData() async {
    final token = await StorageService().getToken();
    if (token == null) return;

    await Provider.of<OwnerItemProvider>(context, listen: false)
        .fetchItems(token, categoryId: selectedCategoryId);
  }

   Future<void> _handleRefresh() async {
    // Memuat ulang kategori dan daftar item secara bersamaan
    await Future.wait([
      _fetchCategories(),
      _fetchData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<OwnerItemProvider>(context);
    final items = itemProvider.items
        .where((item) => item.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Menu Restoran',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Tcolor.primary,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // 🔍 Search
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Makanan...',
                  prefixIcon: const Icon(Icons.search),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),
        
            // 📂 Kategori
            SizedBox(
              height: 60,
              child: isCategoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCategoryTab(null, 'Semua');
                        }
                        final category = categories[index - 1];
                        return _buildCategoryTab(category.id, category.name);
                      },
                    ),
            ),
        
            const SizedBox(height: 8),
        
            // 📋 List Item
            Expanded(
              child: itemProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text('Tidak ada Makanan Yang ditemukan.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(item.name),
                                subtitle: Text(
                                  '${formatPrice(item.price)}',
                                  // 'Rp ${item.price != null ? (item.price is num ? (item.price as num).toStringAsFixed(0) : double.tryParse(item.price.toString())?.toStringAsFixed(0) ?? item.price.toString()) : '0'}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailFoodView(item: item),
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
      ),

      // ➕ Tombol Tambah
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createItem');
        },
        child: const Icon(Icons.add),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryTab(int? id, String label) {
    final isSelected = id == selectedCategoryId;
    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedCategoryId = id;
        });
        await _fetchData();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Tcolor.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
