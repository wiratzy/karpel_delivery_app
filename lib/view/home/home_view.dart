// lib/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/category_cell.dart';
import 'package:karpel_food_delivery/common_widget/popular_restaurant_row.dart';
import 'package:karpel_food_delivery/common_widget/recent_item_row.dart';
import 'package:karpel_food_delivery/common_widget/view_all_title_row.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/home_provider.dart';
import 'package:karpel_food_delivery/view/menu/all_menu_view.dart';
import 'package:karpel_food_delivery/view/menu/category_items_view.dart';
import 'package:karpel_food_delivery/view/menu/item_details_view.dart';
import 'package:karpel_food_delivery/view/more/my_order_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        homeProvider.fetchHomeData(token);
      } else {
        print('No token available for fetching home data');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? "User";

    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeProvider.error != null) {
          return Center(child: Text('Error: ${homeProvider.error}'));
        }

        return Scaffold(
          body: SingleChildScrollView(
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
                        Text(
                          "Good Morning $userName!",
                          style: TextStyle(
                            color: Tcolor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrderView(),
                              ),
                            );
                          },
                          icon: Image.asset(
                            "assets/img/shopping_cart.png",
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search field (jika ada, tambahkan kembali)
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: homeProvider.categories.length,
                      itemBuilder: ((context, index) {
                        final cObj = homeProvider.categories[index];
                        return CategoryCell(
                          cObj: cObj,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryItemsView(
                                  categoryId: cObj.id,
                                  categoryName: cObj.name,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ViewAllTitleRow(
                      title: "Popular Restaurants",
                      onView: () {},
                    ),
                  ),
                  homeProvider.popularRestaurants.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            "No popular restaurants available",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: homeProvider.popularRestaurants.length,
                          itemBuilder: ((context, index) {
                            final pObj = homeProvider.popularRestaurants[index];
                            return PopularRestaurantRow(
                              pObj: {
                                "image": pObj.image,
                                "name": pObj.name,
                                "rate": pObj.rate.toString(),
                                "rating": pObj.rating,
                                "type": pObj.type,
                                "food_type": pObj.foodType,
                              },
                              onTap: () {},
                            );
                          }),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ViewAllTitleRow(
                      title: "Recent Items",
                      onView: () {
                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllMenuView(),
                              ),
                            );
                      },
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: homeProvider.recentItems.length,
                    itemBuilder: ((context, index) {
                      final rObj = homeProvider.recentItems[index];
                      return RecentItemRow(
                        rObj: rObj,
                        onTap: () {
                           Navigator.push(
                        context,
                        MaterialPageRoute(
                         builder: (context) => ItemDetailsView(itemId: rObj.id),
                        ),
                      );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
