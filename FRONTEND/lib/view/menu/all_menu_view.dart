import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/cofing.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/view/menu/item_details_view.dart';
import 'package:karpel_food_delivery/view/more/my_order_view.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/providers/items_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class AllMenuView extends StatefulWidget {
  const AllMenuView({super.key});

  @override
  State<AllMenuView> createState() => _AllMenuViewState();
}

class _AllMenuViewState extends State<AllMenuView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      if (itemsProvider.items.isEmpty) {
        itemsProvider.fetchItems(reset: true);
      }
      if (itemsProvider.categories.isEmpty) {
        itemsProvider.fetchItemCategories();
      }
    });

    _searchController.addListener(() {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      itemsProvider.applySearchFilter(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        itemsProvider.hasMoreItems &&
        !itemsProvider.isLoadingItems) {
      itemsProvider.fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ItemsProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.refreshItems,
            child: Skeletonizer(
              enabled: provider.isLoadingItems && provider.items.isEmpty,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(provider),
                  _buildCategoryChips(provider),
                  _buildItemList(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // AppBar yang modern dengan Search Bar
  SliverAppBar _buildSliverAppBar(ItemsProvider provider) {
    return SliverAppBar(
      backgroundColor: Tcolor.white,
      foregroundColor: Tcolor.primaryText,
      elevation: 1,
      pinned: true,
      floating: true,
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Cari makanan...",
          prefixIcon: Icon(Icons.search, color: Tcolor.secondaryText),
          border: InputBorder.none,
          hintStyle: TextStyle(color: Tcolor.secondaryText),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyOrderView()),
            );
          },
          icon: Image.asset("assets/img/shopping_cart.png",
              width: 25, height: 25),
        ),
      ],
    );
  }

  // Filter kategori dalam bentuk chips
  SliverToBoxAdapter _buildCategoryChips(ItemsProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount:
              provider.isLoadingCategories ? 5 : provider.categories.length,
          itemBuilder: (context, index) {
            final category = provider.isLoadingCategories
                ? ItemCategory.dummy()
                : provider.categories[index];
            final isSelected = provider.selectedCategory?.id == category.id;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  provider.selectCategory(category);
                },
                selectedColor: Tcolor.primary,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: isSelected ? Tcolor.primary : Colors.grey.shade300),
                showCheckmark: false,
              ),
            );
          },
        ),
      ),
    );
  }

  // Tampilan utama (Grid, Pesan Kosong, atau Error)
  Widget _buildItemList(ItemsProvider provider) {
    if (provider.items.isEmpty && !provider.isLoadingItems) {
      return SliverFillRemaining(child: _buildEmptyView());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75, // Atur rasio untuk membuat kartu lebih tinggi
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = provider.isLoadingItems && provider.items.isEmpty
                ? Item.dummy()
                : provider.items[index];
            return _buildItemCard(item, provider.isLoadingItems);
          },
          childCount: provider.isLoadingItems && provider.items.isEmpty
              ? 8
              : provider.items.length,
        ),
      ),
    );
  }

  // Kartu untuk setiap item makanan
  Widget _buildItemCard(Item item, bool isLoading) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetailsView(itemId: item.id)));
            },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  item.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.fastfood_outlined,
                        size: 40, color: Colors.grey.shade400),
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.restaurant.name,
                    style: TextStyle(fontSize: 12, color: Tcolor.secondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                    Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                      item.rate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                      "(${item.rating ?? 0})",
                      style: TextStyle(
                        color: Tcolor.secondaryText,
                        fontSize: 12,
                      ),
                      ),
                    ],
                    ),
                  const SizedBox(height: 6),
                  Text(
                  formatPrice(item.price.toString()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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

  // Tampilan saat tidak ada item ditemukan
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("Tidak Ada Menu Ditemukan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Coba kata kunci atau kategori lain.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
