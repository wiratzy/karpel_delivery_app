import 'package:flutter/material.dart';
import 'package:kons2/providers/customer_order_provider.dart';
import 'package:kons2/providers/driver_provider.dart';
import 'package:kons2/providers/items_provider.dart';
import 'package:kons2/providers/order_provider.dart';
import 'package:kons2/view/home/home_view.dart';
import 'package:kons2/view/more/pick_location_view.dart';
import 'package:kons2/view/owner_restaurant/orderList/resto_order_list_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kons2/services/api_services.dart';
import 'package:kons2/services/storage_services.dart'; // Import service baru
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. Import package ini

import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/providers/tab_provider.dart';
import 'package:kons2/providers/home_provider.dart';
import 'package:kons2/providers/category_items_provider.dart';
import 'package:kons2/providers/item_provider.dart';

import 'package:kons2/view/main_tabview/main_tabview.dart';
import 'package:kons2/view/login/login_view.dart';
import 'package:kons2/view/login/sign_up_view.dart';
import 'package:kons2/view/login/welcome_view.dart';
import 'package:kons2/view/menu/all_menu_view.dart';
import 'package:kons2/view/more/my_order_view.dart';
import 'package:kons2/view/admin/admin_view.dart';
import 'package:kons2/view/driver/driver_view.dart';
import 'package:kons2/view/owner_restaurant/restaurant_owner_view.dart';
import 'package:kons2/view/on_boarding/startup_view.dart';
import 'package:kons2/view/on_boarding/on_boarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // <-- 4. Tambahkan inisialisasi untuk 'id_ID'

  final prefs = await SharedPreferences.getInstance();

  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<ApiService>(),
            context.read<StorageService>(),
          )..init(), // Panggil init untuk memuat sesi
        ),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryItemsProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => CustomerOrderProvider(ApiService()),),
        ChangeNotifierProvider(create: (_) => OrderProvider(ApiService())),
        ChangeNotifierProvider(
          create: (context) => ItemsProvider(
            Provider.of<ApiService>(context, listen: false),
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
                ChangeNotifierProvider(create: (_) => DriverProvider(ApiService())), // <-- INI WAJIB ADA

      ],
      child: MyApp(
        isLoggedIn: isLoggedIn,
        isOnboardingCompleted: isOnboardingCompleted,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isOnboardingCompleted;

  const MyApp(
      {super.key,
      required this.isLoggedIn,
      required this.isOnboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery',
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StartupView(),
      routes: {
        '/main': (context) => const MainTabView(),
        '/login': (context) => const LoginView(),
        '/signup': (context) => const SignUpView(),
        '/welcome': (context) => const WelcomeView(),
        '/home': (context) => const HomeView(),
        '/onBoarding': (context) => const OnBoardingView(),
        '/admin': (context) => const AdminView(),
        '/restaurantOwner': (context) => const RestaurantOwnerHomeView(),
        '/driver': (context) => const DriverView(),
        '/myOrderView': (context) => const MyOrderView(),
        '/mapPicker': (context) => const PickLocationView(),
        '/allMenuView': (context) => const AllMenuView(),
        '/restoTransactions': (context) => RestoOrderListView(),
      },
    );
  }
}
