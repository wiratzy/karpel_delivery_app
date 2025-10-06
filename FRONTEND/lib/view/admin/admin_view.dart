import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
// import yang diperlukan
import 'package:karpel_food_delivery/view/admin/account/customer_view.dart';
import 'package:karpel_food_delivery/view/admin/admin_restaurant_application_view.dart';
import 'package:karpel_food_delivery/view/admin/item_category/admin_item_category_view.dart';
import 'package:karpel_food_delivery/view/admin/resto/admin_restaurant_list_view.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda ingin logout dan keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              // Menggunakan pushNamedAndRemoveUntil untuk membersihkan stack navigasi
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'WELCOME BACK ADMIN !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Tcolor.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Konten Utama (Tombol Kotak)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      // Customer Button
                      _buildDashboardButton(
                        context,
                        title: 'Customer',
                        icon: Icons.people_alt, // Menggunakan Icon bawaan
                        color: Tcolor.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerView(),
                            ),
                          );
                        },
                      ),
                      // Resto Button
                      _buildDashboardButton(
                        context,
                        title: 'Resto',
                        icon: Icons.store, // Menggunakan Icon bawaan
                        color: Tcolor.placeholder,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminRestaurantListView()));
                        },
                      ),
                      // Kategori Makanan Button
                      _buildDashboardButton(
                        context,
                        title: 'Kategori Makanan',
                        icon: Icons.category, // Menggunakan Icon bawaan
                        color: Tcolor.placeholder,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminItemCategoryView()));
                        },
                      ),
                      // Pengajuan Restoran Button
                      _buildDashboardButton(
                        context,
                        title: 'Pengajuan Restoran',
                        icon: Icons.edit_note, // Menggunakan Icon bawaan (atau icons.restaurant_menu)
                        color: Tcolor.primary,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminRestaurantApplicationListView()));
                        },
                      ),
                      // Logout Button
                      _buildDashboardButton(
                        context,
                        title: 'Logout',
                        icon: Icons.logout, // Menggunakan Icon bawaan
                        color: Tcolor.secondaryText,
                        onTap: () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi Logout'),
                              content:
                                  const Text('Apakah kamu yakin ingin logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await auth.logout();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/welcome', (route) => false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk tombol dashboard (kotak)
  Widget _buildDashboardButton(
    BuildContext context, {
    required String title,
    required IconData icon, // <-- Berubah dari iconPath (String) menjadi icon (IconData)
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon( // <-- Menggunakan widget Icon
              icon, // Menggunakan parameter icon (IconData)
              size: 40,
              color: color == Tcolor.primary || color == Tcolor.secondaryText
                  ? Tcolor.white
                  : Tcolor.primaryText,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color == Tcolor.primary || color == Tcolor.secondaryText
                    ? Tcolor.white
                    : Tcolor.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}