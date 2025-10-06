// lib/view/category_items_view.dart
import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/recent_item_row.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/category_items_provider.dart';
import 'package:karpel_food_delivery/view/menu/item_details_view.dart';
import 'package:provider/provider.dart';

class CategoryItemsView extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryItemsView({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryItemsView> createState() => _CategoryItemsViewState();
}

class _CategoryItemsViewState extends State<CategoryItemsView> {
  CategoryItemsProvider? _categoryItemsProvider; // Store provider reference

  @override
  void initState() {
    super.initState();
    // Get provider reference in initState
    _categoryItemsProvider = Provider.of<CategoryItemsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        _categoryItemsProvider!.fetchItemsCategories(token, widget.categoryId);
      } else {
        print('No token available for fetching items');
      }
    });
  }

  @override
  void dispose() {
    // Use stored reference to call clearItems
    _categoryItemsProvider?.clearItems();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryItemsProvider>(
      builder: (context, categoryItemsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.categoryName,
              style: TextStyle(
                color: Tcolor.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Tcolor.primaryText),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: categoryItemsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : categoryItemsProvider.error != null
                  ? Center(child: Text('Error: ${categoryItemsProvider.error}'))
                  : categoryItemsProvider.items.isEmpty
                      ? const Center(child: Text('No items available in this category'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          itemCount: categoryItemsProvider.items.length,
                          itemBuilder: (context, index) {
                            final item = categoryItemsProvider.items[index];
                            return RecentItemRow(
                              rObj: item,
                              onTap: () {
                                 Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailsView(itemId: item.id),
                            ),
                          );
                                // Add navigation to item details if needed
                              },
                            );
                          },
                        ),
        );
      },
    );
  }
}