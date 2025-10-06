import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/providers/customer_restaurant_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'customer_restaurant_list_view.dart';

class CustomerRestaurantWrapper extends StatelessWidget {
  const CustomerRestaurantWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerRestaurantProvider(apiService: ApiService())..fetchRestaurants(),
      child: const CustomerRestaurantListView(),
    );
  }
}
