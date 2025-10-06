import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common_widget/popular_restaurant_row.dart';
import 'package:karpel_food_delivery/models/customer_restaurant_model.dart';
import 'package:karpel_food_delivery/models/home_model.dart'; // Pastikan model Restaurant diimpor
import 'package:karpel_food_delivery/providers/customer_restaurant_detail_provider.dart';
import 'package:karpel_food_delivery/providers/customer_restaurant_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/view/more/customer_restaurant_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/color_extension.dart';

class CustomerRestaurantListView extends StatefulWidget {
  const CustomerRestaurantListView({super.key});

  @override
  State<CustomerRestaurantListView> createState() =>
      _CustomerRestaurantListViewState();
}

class _CustomerRestaurantListViewState
    extends State<CustomerRestaurantListView> {
  final _searchController = TextEditingController();
  int _selectedRatingFilter = 0; // 0 untuk semua, 1-5 untuk rating

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider =
        Provider.of<CustomerRestaurantProvider>(context, listen: false);
    await provider.fetchRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerRestaurantProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Restoran Tersedia'),
            centerTitle: true,
            foregroundColor: Colors.white,
            backgroundColor: Tcolor.primary,
          ),
          body: RefreshIndicator(
            onRefresh: _fetchData,
            child: Column(
              children: [
                _buildSearchAndFilter(provider),
                Expanded(
                  child: _buildBody(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter(CustomerRestaurantProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari nama restoran...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: provider.search,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRatingChip(provider, 0, "Semua"),
                ...List.generate(5, (index) {
                  int rating = index + 1;
                  return _buildRatingChip(provider, rating, "$rating ⭐ Bintang");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(CustomerRestaurantProvider provider, int rating, String label) {
    final bool isSelected = _selectedRatingFilter == rating;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedRatingFilter = rating);
            provider.filterByRating(rating);
          }
        },
        selectedColor: Tcolor.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey.shade200,
        showCheckmark: false,
      ),
    );
  }

  // ===== BAGIAN YANG DIPERBAIKI ADA DI SINI =====
  Widget _buildBody(CustomerRestaurantProvider provider) {
    return Skeletonizer(
      enabled: provider.isLoading,
      child: provider.restaurants.isEmpty && !provider.isLoading
          ? _buildEmptyView()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.isLoading ? 5 : provider.restaurants.length,
              itemBuilder: ((context, index) {
                
                // Gunakan tipe data 'CustomerRestaurant' secara eksplisit
                final CustomerRestaurant restaurant = provider.isLoading
                    ? CustomerRestaurant.dummy()
                    : provider.restaurants[index] as CustomerRestaurant;
                
                return PopularRestaurantRow(
                  pObj: {
                    "image": restaurant.image,
                    "name": restaurant.name,
                    "rate": restaurant.rate.toString(),
                    "rating": restaurant.rating,
                    "type": restaurant.type,
                    "food_type": restaurant.foodType,
                  },
                  // Beri fungsi kosong saat loading, bukan null
                  onTap: provider.isLoading ? () {} : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => CustomerRestaurantDetailProvider(apiService: ApiService()),
                          child: CustomerRestaurantDetailView(restaurantId: restaurant.id),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Tidak Ada Restoran",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Restoran yang Anda cari tidak ditemukan.\nCoba kata kunci atau filter lain.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}