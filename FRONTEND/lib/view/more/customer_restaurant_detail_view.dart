// lib/view/more/customer_restaurant_detail_view.dart

import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common_widget/recent_item_row.dart';
import 'package:karpel_food_delivery/models/review_model.dart';
import 'package:karpel_food_delivery/providers/customer_restaurant_detail_provider.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/view/menu/item_details_view.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomerRestaurantDetailView extends StatefulWidget {
  final int restaurantId;

  const CustomerRestaurantDetailView({super.key, required this.restaurantId});

  @override
  State<CustomerRestaurantDetailView> createState() =>
      _CustomerRestaurantDetailViewState();
}

class _CustomerRestaurantDetailViewState
    extends State<CustomerRestaurantDetailView> {
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider =
        Provider.of<CustomerRestaurantDetailProvider>(context, listen: false);
    provider.fetchRestaurantDetail(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CustomerRestaurantDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.restaurantDetail == null) {
            return _buildLoadingSkeleton();
          }

          if (provider.error != null && provider.restaurantDetail == null) {
            return _buildErrorView(provider.error!);
          }

          if (provider.restaurantDetail == null) {
            return _buildErrorView("Data restoran tidak dapat ditemukan.");
          }

          return _buildSuccessView(provider);
        },
      ),
    );
  }

  // --- WIDGET UNTUK SETIAP STATE ---

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      appBar: AppBar(title: const Text("Memuat...")),
      body: Skeletonizer(
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Bone.square(
                        size: 100,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Bone.text(width: 200, fontSize: 24),
                          const SizedBox(height: 8),
                          const Bone.text(width: 150),
                          const SizedBox(height: 8),
                          const Bone.text(width: 180),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Bone.text(
                    width: 50,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 4,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Bone.text(width: 80),
                  ),
                ),
              ),
              const Divider(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return RecentItemRow(
                    rObj: Item.dummy(),
                    onTap: () {},
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewPreview(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Belum ada ulasan pelanggan."),
      );
    }

    final preview = reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("Ulasan Pelanggan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: preview.length,
            itemBuilder: (context, index) {
              final review = preview[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: review.customerPhoto != null
                                    ? NetworkImage(review.customerPhoto!)
                                    : null,
                                child: review.customerPhoto == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(review.customerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < review.restaurantRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review.reviewText,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showAllReviews(context, reviews),
            child: const Text("Lihat Semua Ulasan"),
          ),
        )
      ],
    );
  }

  void _showAllReviews(BuildContext context, List<Review> reviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<Review> sortedReviews = [...reviews];
        String sortOrder = "desc"; // default: terbesar ke terkecil

        return StatefulBuilder(
          builder: (context, setState) {
            void sortReviews(String order) {
              setState(() {
                sortOrder = order;
                sortedReviews.sort((a, b) => order == "asc"
                    ? a.restaurantRating.compareTo(b.restaurantRating)
                    : b.restaurantRating.compareTo(a.restaurantRating));
              });
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Semua Ulasan",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: sortOrder,
                        items: const [
                          DropdownMenuItem(
                              value: "asc",
                              child: Text("Rating: Kecil → Besar")),
                          DropdownMenuItem(
                              value: "desc",
                              child: Text("Rating: Besar → Kecil")),
                        ],
                        onChanged: (val) {
                          if (val != null) sortReviews(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedReviews.length,
                      itemBuilder: (context, index) {
                        final r = sortedReviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: r.customerPhoto != null
                                  ? NetworkImage(r.customerPhoto!)
                                  : null,
                              child: r.customerPhoto == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(r.customerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < r.restaurantRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(r.reviewText),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined,
                  color: Colors.grey.shade400, size: 80),
              const SizedBox(height: 20),
              Text(
                "Oops! Terjadi Kesalahan",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(CustomerRestaurantDetailProvider provider) {
    final detail = provider.restaurantDetail!;
    final categories = ['Semua', ...provider.categories];

    final List<Item> filteredItems;
    if (_selectedCategory == 'Semua') {
      filteredItems = provider.search.isEmpty
          ? detail.items
          : detail.items
              .where((item) => item.name
                  .toLowerCase()
                  .contains(provider.search.toLowerCase()))
              .toList();
    } else {
      filteredItems = provider.itemsByCategory(_selectedCategory);
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: Text(detail.name),
            pinned: true,
            floating: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                detail.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.restaurant_menu,
                      size: 80, color: Colors.white60),
                ),
              ),
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Info Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.star, color: Tcolor.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(detail.rate ?? "N/A",
                        style: TextStyle(
                            color: Tcolor.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text("(${detail.rating} ulasan)",
                        style: TextStyle(color: Tcolor.secondaryText)),
                  ]),
                  const SizedBox(height: 4),
                  Text("${detail.type} • ${detail.foodType}",
                      style: TextStyle(color: Tcolor.secondaryText)),
                  const SizedBox(height: 4),
                  Text("${detail.location} ",
                      style: TextStyle(color: Tcolor.secondaryText)),
                  const SizedBox(height: 4),
                  Text("${detail.phone} ",
                      style: TextStyle(color: Tcolor.secondaryText)),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: provider.setSearch,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari menu di ${detail.name}...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // TabBar kategori
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                      selectedColor: Tcolor.primary,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24),

            // List menu
            if (filteredItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.menu_book_outlined,
                          color: Colors.grey.shade400, size: 70),
                      const SizedBox(height: 16),
                      const Text("Oops!",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        provider.search.isNotEmpty
                            ? "Menu yang Anda cari tidak ditemukan."
                            : "Restoran ini belum memiliki menu untuk kategori ini.",
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: filteredItems
                    .map((item) => RecentItemRow(
                          rObj: item,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailsView(itemId: item.id),
                            ),
                          ),
                        ))
                    .toList(),
              ),

            const Divider(height: 32),

            // Review section
// Review section
            _buildReviewPreview(detail.reviews),
          ],
        ),
      ),
    );
  }
}
