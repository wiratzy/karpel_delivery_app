import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RestaurantOwnerHomeView extends StatefulWidget {
  const RestaurantOwnerHomeView({super.key});

  @override
  State<RestaurantOwnerHomeView> createState() => _RestaurantOwnerHomeViewState();
}

class _RestaurantOwnerHomeViewState extends State<RestaurantOwnerHomeView> {
  Future<void> handleLogout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  Widget _buildMenuCard({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final username = auth.user?.name ?? "Restaurant";

    return Scaffold(
      backgroundColor: Tcolor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "WELCOME BACK",
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${username.toUpperCase()} !",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1,
                  children: [
                    _buildMenuCard(
                      label: "Transaction",
                      icon: Icons.receipt_long,
                      backgroundColor: Tcolor.primary,
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.pushNamed(context, '/restoTransactions');
                      },
                    ),
                    _buildMenuCard(
                      label: "Resto",
                      icon: Icons.storefront,
                      backgroundColor: Colors.grey.shade300,
                      iconColor: Colors.black54,
                      onTap: () {
                        Navigator.pushNamed(context, '/restoInfo');
                      },
                    ),
                    _buildMenuCard(
                      label: "Food",
                      icon: Icons.food_bank_rounded,
                      backgroundColor: Colors.grey.shade300,
                      iconColor: Colors.black54,
                      onTap: () {
                        Navigator.pushNamed(context, '/restoFoodInfo');
                      },
                    ),
                    _buildMenuCard(
                      label: "Logout",
                      icon: Icons.logout,
                      backgroundColor: Tcolor.primary,
                      iconColor: Colors.white,
                      onTap: handleLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
