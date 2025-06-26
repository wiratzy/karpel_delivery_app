import 'package:flutter/material.dart';
import 'package:kons2/view/menu/item_details_view.dart';
import 'package:provider/provider.dart';
import 'package:kons2/common/color_extension.dart'; // Pastikan path ini benar
import 'package:kons2/common_widget/round_textfield.dart'; // Pastikan path ini benar
import 'package:kons2/common_widget/recent_item_row.dart'; // Pastikan path ini benar
import 'package:kons2/providers/items_provider.dart'; // Pastikan path ini benar

class AllMenuView extends StatefulWidget {
  const AllMenuView({super.key});

  @override
  State<AllMenuView> createState() => _AllMenuViewState();
}

class _AllMenuViewState extends State<AllMenuView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode _searchFocusNode = FocusNode(); // Untuk mengelola fokus TextField

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Pastikan provider sudah diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      if (itemsProvider.items.isEmpty && !itemsProvider.isLoadingItems) {
        itemsProvider.fetchItems(reset: true);
      }
      if (itemsProvider.categories.isEmpty &&
          !itemsProvider.isLoadingCategories) {
        itemsProvider.fetchItemCategories();
      }
    });

    _searchController.addListener(() {
      // Panggil applySearchFilter setelah ada jeda atau ketika user selesai mengetik
      // Untuk performa yang lebih baik, bisa menggunakan debounce
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      itemsProvider.applySearchFilter(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Fungsi untuk mendeteksi scroll dan memuat lebih banyak item
  void _onScroll() {
    final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        itemsProvider.hasMoreItems &&
        !itemsProvider.isLoadingItems) {
      itemsProvider.fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemsProvider>(
      builder: (context, itemsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Tcolor.white,
            elevation: 0,
            title: Row(
              children: [
                Expanded(
                  child: RoundTextfield(
                    controller: _searchController,
                    hintText: "Search Food",
                    bgColor: Tcolor.textfield,
                    left: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                    focusNode: _searchFocusNode, // Menghubungkan FocusNode
                  ),
                ),
                if (_searchController
                    .text.isNotEmpty) // Tampilkan tombol X jika ada teks
                  IconButton(
                    icon: Icon(Icons.clear, color: Tcolor.secondaryText),
                    onPressed: () {
                      _searchController.clear();
                      itemsProvider
                          .resetSearchFilter(); // Reset filter pencarian di provider
                      _searchFocusNode.unfocus(); // Hapus fokus dari TextField
                    },
                  ),
              ],
            ),
            // Anda bisa menambahkan ikon keranjang atau notifikasi di sini
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Implement notification button action
                },
                icon: Image.asset(
                  "assets/img/shopping_cart.png",
                  width: 25,
                  height: 25,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: itemsProvider
                .refreshItems, // Panggil fungsi refresh di provider
            child: SingleChildScrollView(
              controller: _scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Untuk memastikan RefreshIndicator selalu berfungsi
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Kategori (Chips)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        color: Tcolor.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (itemsProvider.isLoadingCategories)
                    const Center(child: CircularProgressIndicator())
                  else if (itemsProvider.categories.isEmpty)
                    const Center(child: Text("No categories available."))
                  else
                    SizedBox(
                      height: 40, // Tinggi untuk daftar chip kategori
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: itemsProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = itemsProvider.categories[index];
                          final isSelected =
                              itemsProvider.selectedCategory?.id == category.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ActionChip(
                              label: Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Tcolor.white
                                      : Tcolor.primaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: isSelected
                                  ? Tcolor.primary
                                  : Tcolor.textfield,
                              onPressed: () {
                                itemsProvider.selectCategory(category);
                                // Gulir ke atas daftar item setelah filter diterapkan
                                _scrollController.animateTo(
                                  0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 15),

                  // Bagian Daftar Item
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Popular Items", // Atau "All Items"
                      style: TextStyle(
                        color: Tcolor.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (itemsProvider.items.isEmpty &&
                      itemsProvider.isLoadingItems)
                    const Center(child: CircularProgressIndicator())
                  else if (itemsProvider.items.isEmpty &&
                      !itemsProvider.isLoadingItems)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                            "No items found for the current filter/search."),
                      ),
                    )
                  else
                    ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // agar tidak konflik dengan SingleChildScrollView
                      shrinkWrap: true,
                      itemCount: itemsProvider.items.length +
                          (itemsProvider.hasMoreItems ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < itemsProvider.items.length) {
                          final item = itemsProvider.items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: RecentItemRow(
                              rObj: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailsView(itemId: item.id),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          // Menampilkan CircularProgressIndicator di bagian bawah daftar saat memuat lebih banyak item
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),

                  // Padding tambahan jika perlu untuk scroll
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
