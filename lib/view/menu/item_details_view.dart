import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kons2/common_widget/restaurant_conflict_dialog.dart';
import 'package:kons2/models/home_model.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_icon_button.dart';
import '../../providers/item_provider.dart';
import '../more/my_order_view.dart';

class ItemDetailsView extends StatefulWidget {
  final int itemId;
  const ItemDetailsView({super.key, required this.itemId});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  int qty = 1;
  bool isFav = false;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      Provider.of<ItemProvider>(context, listen: false)
          .fetchItemDetails(authProvider.token!, widget.itemId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to view item details')),
      );
      Navigator.pop(context);
    }
  }

 void addToCart() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final itemProvider = Provider.of<ItemProvider>(context, listen: false);

  if (authProvider.token == null || authProvider.user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please login to add to cart')),
    );
    return;
  }

  try {
    await itemProvider.addToCart(
      authProvider.token!,
      authProvider.user!.id,
      widget.itemId,
      qty,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item added to cart')),
    );
    print('Item added successfully, navigating to MyOrderView');
    Navigator.pushReplacementNamed(context, '/myOrderView');
  } catch (e) {
    print('Caught error in addToCart: $e');
    if (e.toString().contains('409') || e.toString().toLowerCase().contains('different restaurant')) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) => RestaurantConflictDialog(
          itemId: widget.itemId,
          qty: qty,
          onConfirm: () {
            Navigator.pushReplacementNamed(context, '/myOrderView');
          },
        ),
      );
      print('Bottom sheet shown for conflict');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  Widget buildItemDetails(Item item) {
    var media = MediaQuery.of(context).size;
    final double itemRate = double.tryParse(item.rate) ?? 0.0;
    final double itemPrice = double.tryParse(item.price ?? '0.0') ?? 0.0;

    if (totalPrice == 0.0) {
      totalPrice = itemPrice * qty;
    }

    return Scaffold(
      backgroundColor: Tcolor.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.network(
            item.image,
            width: media.width,
            height: media.width,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image load error: $error');
              return Image.asset(
                'assets/img/detail_top.png',
                width: media.width,
                height: media.width,
                fit: BoxFit.cover,
              );
            },
          ),
          Container(
            width: media.width,
            height: media.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(height: media.width - 60),
                      Container(
                        decoration: BoxDecoration(
                          color: Tcolor.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 35),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  color: Tcolor.primaryText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                item.restaurant.name,
                                style: TextStyle(
                                  color: Tcolor.secondaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      IgnorePointer(
                                        ignoring: true,
                                        child: RatingBar.builder(
                                          initialRating: itemRate,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemPadding:
                                              const EdgeInsets.symmetric(horizontal: 1.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Tcolor.primary,
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$itemRate Star Ratings (${item.rating} reviews)",
                                        style: TextStyle(
                                          color: Tcolor.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rp ${itemPrice.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          color: Tcolor.primaryText,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "/per Portion",
                                        style: TextStyle(
                                          color: Tcolor.primaryText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Delivery Fee",
                                style: TextStyle(
                                  color: Tcolor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Rp ${item.restaurant.deliveryFee.toStringAsFixed(0)} (Pembayaran Langsung Ke Driver)",
                                style: TextStyle(
                                  color: Tcolor.secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Description",
                                style: TextStyle(
                                  color: Tcolor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "${item.type} dish from ${item.restaurant.name}. Freshly prepared with high-quality ingredients.",
                                style: TextStyle(
                                  color: Tcolor.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Divider(
                                color: Tcolor.secondaryText.withOpacity(0.4),
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                children: [
                                  Text(
                                    "Number of Portions",
                                    style: TextStyle(
                                      color: Tcolor.primaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        qty = qty - 1;
                                        if (qty < 1) qty = 1;
                                        final itemPrice =
                                            double.tryParse(item.price ?? '0.0') ?? 0.0;
                                        totalPrice = itemPrice * qty;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Tcolor.primary,
                                        borderRadius: BorderRadius.circular(12.5),
                                      ),
                                      child: Text(
                                        "-",
                                        style: TextStyle(
                                          color: Tcolor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Tcolor.primary),
                                      borderRadius: BorderRadius.circular(12.5),
                                    ),
                                    child: Text(
                                      qty.toString(),
                                      style: TextStyle(
                                        color: Tcolor.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        qty = qty + 1;
                                        final itemPrice =
                                            double.tryParse(item.price ?? '0.0') ?? 0.0;
                                        totalPrice = itemPrice * qty;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Tcolor.primary,
                                        borderRadius: BorderRadius.circular(12.5),
                                      ),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          color: Tcolor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    width: media.width * 0.25,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Tcolor.primary,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(35),
                                        bottomRight: Radius.circular(35),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 10,
                                            right: 20,
                                          ),
                                          width: media.width - 80,
                                          height: 120,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(35),
                                              bottomLeft: Radius.circular(35),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Total Price",
                                                style: TextStyle(
                                                  color: Tcolor.primaryText,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Rp ${totalPrice.toStringAsFixed(0)}",
                                                style: TextStyle(
                                                  color: Tcolor.primaryText,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              SizedBox(
                                                width: 180,
                                                height: 20,
                                                child: RoundIconButton(
                                                  title: "Add to cart",
                                                  icon: "assets/img/shopping_add.png",
                                                  color: Tcolor.primary,
                                                  onPressed: addToCart,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: addToCart,
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(22.5),
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
                                              "assets/img/shopping_cart.png",
                                              width: 20,
                                              height: 20,
                                              color: Tcolor.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  Container(
                    height: media.width - 20,
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isFav = !isFav;
                        });
                      },
                      child: Image.asset(
                        isFav
                            ? "assets/img/favorites_btn.png"
                            : "assets/img/favorites_btn_2.png",
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          "assets/img/btn_back.png",
                          width: 20,
                          height: 20,
                          color: Tcolor.white,
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
                          color: Tcolor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ItemProvider, (bool, Item?)>(
      selector: (context, provider) => (provider.isLoading, provider.item),
      builder: (context, data, child) {
        final isLoading = data.$1;
        final item = data.$2;

        if (isLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (item == null) {
          return Scaffold(
            body: Center(child: Text('No item details')),
          );
        }
        return buildItemDetails(item);
      },
    );
  }
}