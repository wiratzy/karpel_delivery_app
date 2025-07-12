import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/view/admin/account/customer_view.dart';
import 'package:provider/provider.dart';

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
              Navigator.pushReplacementNamed(context, '/welcome');
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
    var media = MediaQuery.of(context).size;

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
                    childAspectRatio: 1.0,
                    children: [
                      // Customer Button
                      _buildDashboardButton(
                        context,
                        title: 'Customer',
                        iconPath:
                            'assets/img/icon_person.png', // Ganti dengan path ikon yang sesuai
                        color: Tcolor.primary,
                        onTap: () {
                          // Tambahkan aksi untuk Customer (misalnya navigasi ke halaman Customer)
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
                        iconPath:
                            'assets/img/icon_store.png', // Ganti dengan path ikon yang sesuai
                        color: Tcolor.placeholder,
                        onTap: () {
                          // Tambahkan aksi untuk Resto
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigasi ke Resto')),
                          );
                        },
                      ),
                      // Courier Button
                      _buildDashboardButton(
                        context,
                        title: 'Courier',
                        iconPath:
                            'assets/img/icon_bike.png', // Ganti dengan path ikon yang sesuai
                        color: Tcolor.placeholder,
                        onTap: () {
                          // Tambahkan aksi untuk Courier
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Navigasi ke Courier')),
                          );
                        },
                      ),
                      // Transaction Button
                      _buildDashboardButton(
                        context,
                        title: 'Transaction',
                        iconPath:
                            'assets/img/icon_document.png', // Ganti dengan path ikon yang sesuai
                        color: Tcolor.primary,
                        onTap: () {
                          // Tambahkan aksi untuk Transaction
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Navigasi ke Transaction')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Footer (Tombol Bundar)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: Tcolor.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFooterButton(
                      iconPath:
                          'assets/img/icon_home.png', // Ganti dengan path ikon yang sesuai
                      color: Tcolor.primary,
                      onTap: () {
                        // Tambahkan aksi untuk Home
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kembali ke Home')),
                        );
                      },
                    ),
                    _buildFooterButton(
                      iconPath:
                          'assets/img/icon_settings.png', // Ganti dengan path ikon yang sesuai
                      color: Tcolor.placeholder,
                      onTap: () {
                        // Tambahkan aksi untuk Settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Buka Settings')),
                        );
                      },
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

  // Widget untuk tombol dashboard (kotak)
  Widget _buildDashboardButton(
    BuildContext context, {
    required String title,
    required String iconPath,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
              color:
                  color == Tcolor.primary ? Tcolor.white : Tcolor.primaryText,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color:
                    color == Tcolor.primary ? Tcolor.white : Tcolor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tombol footer (bundar)
  Widget _buildFooterButton({
    required String iconPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 20,
            height: 20,
            color: color == Tcolor.primary ? Tcolor.white : Tcolor.primaryText,
          ),
        ),
      ),
    );
  }
}
