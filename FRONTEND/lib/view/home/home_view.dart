// lib/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/category_cell.dart';
import 'package:karpel_food_delivery/common_widget/popular_restaurant_row.dart';
import 'package:karpel_food_delivery/common_widget/recent_item_row.dart';
import 'package:karpel_food_delivery/common_widget/view_all_title_row.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/customer_restaurant_detail_provider.dart';
import 'package:karpel_food_delivery/providers/home_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/view/menu/all_menu_view.dart';
import 'package:karpel_food_delivery/view/menu/category_items_view.dart';
import 'package:karpel_food_delivery/view/menu/item_details_view.dart';
import 'package:karpel_food_delivery/view/more/customer_restaurant_detail_view.dart';
import 'package:karpel_food_delivery/view/more/customer_restaurant_list_view.dart';
import 'package:karpel_food_delivery/view/more/my_order_view.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      homeProvider.fetchHomeData(token);
    } else {
      print('No token available for fetching home data');
    }
  }

  String getGreeting() {
    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final hour = wib.hour;

    if (hour >= 5 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? "User";

    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Tampilkan error screen jika ada error dan data kosong
        if (homeProvider.error != null && homeProvider.categories.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${homeProvider.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadHomeData,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _loadHomeData,
            color: Tcolor.primary,
            child: Skeletonizer(
              enabled: homeProvider.isLoading,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 46),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${getGreeting()}, $userName!",
                                style: TextStyle(
                                  color: Tcolor.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyOrderView()),
                                );
                              },
                              icon: Image.asset("assets/img/shopping_cart.png",
                                  width: 25, height: 25),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: homeProvider.isLoading
                              ? 5
                              : homeProvider.categories.length,
                          itemBuilder: ((context, index) {
                            final cObj = homeProvider.isLoading
                                ? ItemCategory(
                                    id: 0, name: "Category Name", image: "")
                                : homeProvider.categories[index];

                            return CategoryCell(
                                cObj: cObj,
                                onTap: () {
                                  if (!homeProvider.isLoading) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryItemsView(
                                                    categoryId: cObj.id,
                                                    categoryName: cObj.name)));
                                  }
                                });
                          }),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ViewAllTitleRow(
                            title: "Restoran Terbaru",
                            onView: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CustomerRestaurantListView()));
                            }),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        // Beri jumlah item palsu saat loading
                        itemCount: homeProvider.isLoading
                            ? 3
                            : homeProvider.popularRestaurants.length,
                        itemBuilder: ((context, index) {
                          // Gunakan data dummy saat loading
                          final pObj = homeProvider.isLoading
                              ? Restaurant(
                                  id: 0,
                                  name: "Restaurant Name",
                                  image: "",
                                  rate: 4.5,
                                  rating: 50,
                                  type: "Type",
                                  foodType: "Food Type",
                                  deliveryFee: 5000)
                              : homeProvider.popularRestaurants[index];

                          return PopularRestaurantRow(
                            pObj: {
                              "image": pObj.image,
                              "name": pObj.name,
                              "rate": pObj.rate.toString(),
                              "rating": pObj.rating,
                              "type": pObj.type,
                              "food_type": pObj.foodType,
                            },
                            onTap: () {
                              if (!homeProvider.isLoading) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                              create: (_) =>
                                                  CustomerRestaurantDetailProvider(
                                                      apiService: ApiService()),
                                              child:
                                                  CustomerRestaurantDetailView(
                                                      restaurantId: pObj.id),
                                            )));
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ViewAllTitleRow(
                            title: "Menu Terbaru",
                            onView: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AllMenuView()));
                            }),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        // Beri jumlah item palsu saat loading
                        itemCount: homeProvider.isLoading
                            ? 4
                            : homeProvider.recentItems.length,
                        itemBuilder: ((context, index) {
                          final rObj = homeProvider.isLoading
                              ? Item(
                                  id: 0,
                                  name: "Recent Item Name",
                                  image: "",
                                  rate: "0",
                                  rating: 20,
                                  type: "Type",
                                  price: "25000",
                                  restaurant: Restaurant.dummy())
                              : homeProvider.recentItems[index];

                          return RecentItemRow(
                              rObj: rObj,
                              onTap: () {
                                if (!homeProvider.isLoading) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ItemDetailsView(
                                              itemId: rObj.id)));
                                }
                              });
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Tambahkan constructor dummy pada model Anda jika belum ada, agar lebih mudah.
// Contoh di file home_model.dart:

/*
class Restaurant {
  // ... properti lainnya
  
  // Constructor dummy untuk skeletonizer
  Restaurant.dummy()
      : id = 0,
        name = "Restaurant Name",
        image = "",
        rate = 4.5,
        rating = 50,
        type = "Type",
        foodType = "Food Type",
        deliveryFee = 5000;
}
*/
