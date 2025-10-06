import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan import ini untuk SystemChrome
import 'package:karpel_food_delivery/models/driver_model.dart';
import 'package:karpel_food_delivery/providers/AdminRestaurantApplicationProvider.dart';
import 'package:karpel_food_delivery/providers/admin_item_category_provider.dart';
import 'package:karpel_food_delivery/providers/admin_restaurant_provider.dart';
import 'package:karpel_food_delivery/providers/create_item_provider.dart';
import 'package:karpel_food_delivery/providers/customer_order_provider.dart';
import 'package:karpel_food_delivery/providers/customer_restaurant_provider.dart';
import 'package:karpel_food_delivery/providers/driver_provider.dart';
import 'package:karpel_food_delivery/providers/edit_item_provider.dart';
import 'package:karpel_food_delivery/providers/items_provider.dart';
import 'package:karpel_food_delivery/providers/order_provider.dart';
import 'package:karpel_food_delivery/providers/owner_driver_provider.dart';
import 'package:karpel_food_delivery/providers/owner_item_provider.dart';
import 'package:karpel_food_delivery/view/home/home_view.dart';
import 'package:karpel_food_delivery/view/more/pick_location_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/driver_resto/create_driver_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/driver_resto/edit_driver_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/driver_resto/resto_driver_info_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/food_resto/create_food_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/food_resto/resto_food_info_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/orderList/resto_order_list_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/providers/tab_provider.dart';
import 'package:karpel_food_delivery/providers/home_provider.dart';
import 'package:karpel_food_delivery/providers/category_items_provider.dart';
import 'package:karpel_food_delivery/providers/item_provider.dart';

import 'package:karpel_food_delivery/view/main_tabview/main_tabview.dart';
import 'package:karpel_food_delivery/view/login/login_view.dart';
import 'package:karpel_food_delivery/view/login/sign_up_view.dart';
import 'package:karpel_food_delivery/view/login/welcome_view.dart';
import 'package:karpel_food_delivery/view/menu/all_menu_view.dart';
import 'package:karpel_food_delivery/view/more/my_order_view.dart';
import 'package:karpel_food_delivery/view/admin/admin_view.dart';
import 'package:karpel_food_delivery/view/driver/driver_view.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/restaurant_owner_view.dart';
import 'package:karpel_food_delivery/view/on_boarding/startup_view.dart';
import 'package:karpel_food_delivery/view/on_boarding/on_boarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mengunci orientasi ke potret
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting('id_ID', null);

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
          )..init(),
        ),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryItemsProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => AdminRestaurantApplicationProvider()),
        ChangeNotifierProvider(
          create: (_) => CustomerOrderProvider(ApiService()),
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider(ApiService())),
        ChangeNotifierProvider(
          create: (_) => CreateItemProvider(ApiService()),
        ),
        ChangeNotifierProvider(create: (_) => OwnerItemProvider(ApiService())),
        ChangeNotifierProvider(create: (_) => CreateItemProvider(ApiService())),
        ChangeNotifierProvider(
          create: (context) => ItemsProvider(
            Provider.of<ApiService>(context, listen: false),
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EditItemProvider(ApiService()),
        ),
        ChangeNotifierProvider(create: (_) => DriverProvider(ApiService())),
        ChangeNotifierProvider(
          create: (_) => OwnerDriverProvider(apiService: ApiService())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminRestaurantProvider(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminItemCategoryProvider(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerRestaurantProvider(apiService: ApiService()),
        ),
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
        '/restoFoodInfo': (context) => const RestoFoodInfoView(),
        '/restoDriverInfo': (context) => const RestoDriverInfoView(),
        '/createItem': (context) => ChangeNotifierProvider(
              create: (_) => CreateItemProvider(ApiService()),
              child: const CreateItemView(),
            ),
        '/createDriver': (_) => const CreateDriverView(),
        '/editDriver': (context) {
          final driver = ModalRoute.of(context)!.settings.arguments as Driver;
          return EditDriverView(driver: driver);
        },
      },
    );
  }
}