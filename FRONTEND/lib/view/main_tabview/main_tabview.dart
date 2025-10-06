import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/tab_button.dart'; // Pastikan path ini benar
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/view/home/home_view.dart';
import 'package:karpel_food_delivery/view/more/more_view.dart';
import 'package:karpel_food_delivery/view/profile/profile_view.dart';
import 'package:provider/provider.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  // 1. Kelola halaman dan tab menggunakan List untuk kode yang lebih bersih
  int _selectedIndex = 0; // Ganti nama `selectTab` menjadi `_selectedIndex` yang lebih umum
  final List<Widget> _pages = [
    const HomeView(),    // Index 0
    const ProfileView(), // Index 1
    const MoreView(),    // Index 2
  ];

  // Fungsi untuk mengubah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 2. Sempurnakan dialog konfirmasi keluar/logout
  Future<bool> _onWillPop() async {
    // Gunakan `context` yang aman (jika widget masih ter-mount)
    if (!mounted) return false;

    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Tutup dialog
            child: Text('Tidak', style: TextStyle(color: Tcolor.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Tutup dialog dan konfirmasi logout
            child: Text('Ya, Logout', style: TextStyle(color: Tcolor.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Panggil logout dari AuthProvider
      await Provider.of<AuthProvider>(context, listen: false).logout();
      // Navigasi ke halaman welcome setelah logout
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
      return false; // Mencegah aplikasi keluar langsung, karena sudah di-handle navigasi
    }

    // Jika pengguna memilih "Tidak" atau menutup dialog, jangan lakukan apa-apa
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // `WillPopScope` digantikan oleh `PopScope` di Flutter versi baru untuk kontrol yang lebih baik.
    // Jika Anda menggunakan Flutter lama, `WillPopScope` masih bisa digunakan.
    return PopScope(
      canPop: false, // Mencegah tombol kembali bawaan
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onItemTapped(0), // Selalu kembali ke Home (index 0)
          shape: const CircleBorder(),
          backgroundColor: _selectedIndex == 0 ? Tcolor.primary : Tcolor.placeholder,
          elevation: 2.0,
          child: Image.asset(
            "assets/img/tab_home.png", // Pastikan path asset benar
            width: 30,
            height: 30,
            // Beri warna pada ikon jika FAB tidak aktif
            color: _selectedIndex == 0 ? Tcolor.white : Tcolor.primaryText,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          elevation: 8,
          surfaceTintColor: Tcolor.white,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Tab Profile (kiri)
              TabButton(
                title: "Profile",
                onTap: () => _onItemTapped(1),
                icon: "assets/img/tab_profile.png",
                isSelected: _selectedIndex == 1,
              ),
              // Spacer untuk memberikan ruang bagi FloatingActionButton
              const SizedBox(width: 40),
              // Tab More (kanan)
              TabButton(
                title: "More",
                onTap: () => _onItemTapped(2),
                icon: "assets/img/tab_more.png",
                isSelected: _selectedIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}