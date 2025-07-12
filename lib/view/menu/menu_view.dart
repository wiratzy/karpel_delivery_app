import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/category_items_provider.dart';
import 'package:karpel_food_delivery/view/menu/menu_items_view.dart';
import 'package:karpel_food_delivery/view/more/my_order_view.dart';
import 'package:provider/provider.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  TextEditingController txtSearch = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final categoryItemsProvider = Provider.of<CategoryItemsProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        categoryItemsProvider.fetchCategories(token);
      } else {
        print('No token available for fetching categories');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 180),
            width: media.width * 0.27,
            height: media.height * 0.6,
            decoration: BoxDecoration(
              color: Tcolor.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),
          SingleChildScrollView(
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
                          "Menu",
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RoundTextfield(
                      hintText: "Search Food",
                      controller: txtSearch,
                      left: Container(
                        alignment: Alignment.center,
                        width: 30,
                        child: Image.asset(
                          "assets/img/search.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer<CategoryItemsProvider>(
                    builder: (context, categoryItemsProvider, child) {
                      if (categoryItemsProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (categoryItemsProvider.error != null) {
                        return Center(child: Text('Error: ${categoryItemsProvider.error}'));
                      }

                      if (categoryItemsProvider.categories.isEmpty) {
                        return const Center(child: Text('No categories available'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: categoryItemsProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryItemsProvider.categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuItemsView(mObj: category), // Kirim objek ItemCategory
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 8, bottom: 8, right: 20),
                                  width: media.width - 100,
                                  height: 90,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 7,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      category.imageUrl, // Perbaiki CategoryImageUrl menjadi imageUrl
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Image load failed for ${category.imageUrl}: $error');
                                        return Image.asset(
                                          'assets/img/default_category.png',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              color: Tcolor.primaryText,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${category.itemsCount} items",
                                            style: TextStyle(
                                              color: Tcolor.secondaryText,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(17.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        "assets/img/btn_next.png",
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}