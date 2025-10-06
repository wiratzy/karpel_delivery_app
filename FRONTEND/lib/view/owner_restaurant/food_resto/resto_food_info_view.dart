import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/food_resto/detail_food_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/restaurant_owner_view.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/providers/owner_item_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class RestoFoodInfoView extends StatefulWidget {
  const RestoFoodInfoView({super.key});

  @override
  State<RestoFoodInfoView> createState() => _RestoFoodInfoViewState();
}

class _RestoFoodInfoViewState extends State<RestoFoodInfoView> {
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<ItemCategory> _categories = [];
  bool _isCategoryLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    // Memuat data kategori dan item secara bersamaan
    await Future.wait([
      _fetchCategories(),
      _fetchItems(),
    ]);
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() => _isCategoryLoading = true);
    try {
      final token = await StorageService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');
      final result = await ApiService().fetchItemCategories(token: token);
      if (mounted) setState(() => _categories = result);
    } catch (e) {
      print('❌ Gagal ambil kategori: $e');
    } finally {
      if (mounted) setState(() => _isCategoryLoading = false);
    }
  }

  Future<void> _fetchItems() async {
    final token = await StorageService().getToken();
    if (token == null || !mounted) return;
    await Provider.of<OwnerItemProvider>(context, listen: false)
        .fetchItems(token, categoryId: _selectedCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<OwnerItemProvider>(context);
    final items = itemProvider.items
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      // Menggunakan CustomScrollView untuk layout yang lebih dinamis
      body: RefreshIndicator(
        onRefresh: _fetchInitialData,
        child: Skeletonizer(
          enabled: itemProvider.isLoading && items.isEmpty,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildSearchBar(),
              _buildCategoryChips(),
              _buildItemList(context, itemProvider, items),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createItem').then((_) => _fetchItems());
        },
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      title: const Text('Menu Restoran Saya'),
      backgroundColor: Tcolor.primary,
      foregroundColor: Colors.white,
      pinned: true,
      floating: true,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement( // Menggunakan pushReplacement agar tidak menumpuk
            context,
            MaterialPageRoute(builder: (context) => const RestaurantOwnerHomeView()),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Cari Makanan...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _isCategoryLoading ? 5 : _categories.length + 1,
          itemBuilder: (context, index) {
            if (_isCategoryLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Chip(label: Text('Loading...')),
              );
            }
            if (index == 0) {
              return _buildCategoryChip(null, 'Semua');
            }
            final category = _categories[index - 1];
            return _buildCategoryChip(category.id, category.name);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(int? id, String label) {
    final isSelected = id == _selectedCategoryId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedCategoryId = id);
            _fetchItems();
          }
        },
        selectedColor: Tcolor.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? Tcolor.primary : Colors.grey.shade300),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildItemList(BuildContext context, OwnerItemProvider provider, List<Item> items) {
    if (items.isEmpty && !provider.isLoading) {
      return SliverFillRemaining(child: _buildEmptyView());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = provider.isLoading ? Item.dummy() : items[index];
            return _buildItemCard(item, provider.isLoading);
          },
          childCount: provider.isLoading ? 8 : items.length,
        ),
      ),
    );
  }

  Widget _buildItemCard(Item item, bool isLoading) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return GestureDetector(
      onTap: isLoading ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailFoodView(item: item)),
        ).then((_) => _fetchItems());
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  item.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.fastfood_outlined, size: 40, color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(double.tryParse(item.price!) ?? 0),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Tcolor.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("Belum Ada Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Tambahkan menu pertama Anda\ndengan menekan tombol '+' di bawah.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}