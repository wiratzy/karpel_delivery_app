import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/cofing.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/round_button.dart';
import 'package:karpel_food_delivery/view/more/checkout_view.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/item_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      if (authProvider.token != null) {
        itemProvider.fetchCartItems(authProvider.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to view your cart')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        if (itemProvider.isLoading) {
          return Scaffold(
            backgroundColor: Tcolor.white,
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (itemProvider.error != null) {
          return Scaffold(
            backgroundColor: Tcolor.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${itemProvider.error}'),
                  const SizedBox(height: 10),
                  RoundButton(
                    title: 'Retry',
                    onPressed: () {
                      if (authProvider.token != null) {
                        itemProvider.fetchCartItems(authProvider.token!);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (itemProvider.cartItems.isEmpty) {
          return Scaffold(
            backgroundColor: Tcolor.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/img/empty_cart.png", width: 150),
                  const SizedBox(height: 20),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final cartItem = itemProvider.cartItems.first;
        final restaurant = cartItem.item.restaurant;

        return Scaffold(
          backgroundColor: Tcolor.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 46),
                _buildHeader(context),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          restaurant.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: TextStyle(
                                color: Tcolor.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Image.asset("assets/img/rate.png",
                                    width: 10, height: 10),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rate.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Tcolor.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "(${restaurant.rating} Ratings)",
                                  style: TextStyle(
                                    color: Tcolor.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  restaurant.type,
                                  style: TextStyle(
                                    color: Tcolor.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                                const Text(" . "),
                                Text(
                                  restaurant.foodType ?? "-",
                                  style: TextStyle(
                                    color: Tcolor.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Image.asset("assets/img/location-pin.png",
                                    width: 13, height: 13),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    restaurant.location ?? "No location info",
                                    style: TextStyle(
                                      color: Tcolor.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCartItemList(itemProvider, authProvider.token!),
                const SizedBox(height: 25),
                _buildSummary(itemProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "My Order",
              style: TextStyle(
                color: Tcolor.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemList(ItemProvider itemProvider, String token) {
    return Container(
      decoration: BoxDecoration(color: Tcolor.textfield),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: itemProvider.cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cartItem = itemProvider.cartItems[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.item.name,
                            style: TextStyle(
                              color: Tcolor.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatPrice(cartItem.price),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        cartItem.item.image,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    itemProvider.updatingItemId == cartItem.item.id
                        ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              itemProvider.decreaseQuantity(
                                  token, cartItem.item.id);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        cartItem.quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    itemProvider.updatingItemId == cartItem.item.id
                        ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              itemProvider.increaseQuantity(
                                  token, cartItem.item.id);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(ItemProvider itemProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          _row("Sub Total",
              formatPrice(itemProvider.subtotal.toStringAsFixed(2))),
          const SizedBox(height: 8),
          _row("Delivery fee",
              formatPrice(itemProvider.deliveryCost.toStringAsFixed(2))),
          const SizedBox(height: 15),
          Divider(color: Tcolor.secondaryText.withOpacity(0.5)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  formatPrice(itemProvider.total.toStringAsFixed(2)),
                  key: ValueKey(itemProvider.total),
                  style: TextStyle(
                    color: Tcolor.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          RoundButton(
            title: "Checkout",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckoutView(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool isBold = false, double fontSize = 13}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Tcolor.primaryText,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Tcolor.primary,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
