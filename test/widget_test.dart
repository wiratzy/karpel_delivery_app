import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karpel_food_delivery/models/user_model.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/home_provider.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/view/home/home_view.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomeView displays categories', (WidgetTester tester) async {
    // Dummy UserModel
    final dummyUser = User(id: 1, name: "test", address: "test_address", email: "test_email", phone: "053535353",role: "customer");
    final _apiService = ApiService();
    // Inisialisasi provider
    final homeProvider = HomeProvider();
    final authProvider = AuthProvider(_apiService);

    // Set data dummy ke AuthProvider
    authProvider.setUserForTesting(dummyUser);

    // Set data dummy ke HomeProvider
    homeProvider.setCategoriesForTesting([
      ItemCategory(id: 1, name: 'Pizza', image: "item_1.png", itemsCount: 0),
      ItemCategory(id: 2, name: 'Burger', image: "item_2.png", itemsCount: 0),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: homeProvider),
        ],
        child: const MaterialApp(home: HomeView()),
      ),
    );

    await tester.pumpAndSettle(); // Tunggu build selesai

    // Verifikasi elemen muncul
    expect(find.textContaining('Good Morning'), findsOneWidget);
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Burger'), findsOneWidget);
  });
}
