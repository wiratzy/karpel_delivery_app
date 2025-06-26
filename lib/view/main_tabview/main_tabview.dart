import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/tab_button.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/view/home/home_view.dart';
import 'package:kons2/view/menu/menu_view.dart';
import 'package:kons2/view/more/more_view.dart';
import 'package:kons2/view/offer/offer_view.dart';
import 'package:kons2/view/profile/profile_view.dart';
import 'package:provider/provider.dart';

class MainTabview extends StatefulWidget {
  const MainTabview({super.key});

  @override
  State<MainTabview> createState() => _MainTabviewState();
}

class _MainTabviewState extends State<MainTabview> {
  int selectTab = 2;
  final PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const HomeView();

  Future<bool> _onWillPop() async {
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: PageStorage(bucket: storageBucket, child: selectPageView),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {
              if (selectTab != 2) {
                print('Switching to HomeView');
                selectTab = 2;
                selectPageView = const HomeView();
                setState(() {});
              }
            },
            shape: const CircleBorder(),
            backgroundColor:
                selectTab == 2 ? Tcolor.primary : Tcolor.placeholder,
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/img/tab_home.png",
                width: 35,
                height: 35,
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Tcolor.white,
          surfaceTintColor: Tcolor.white,
          shadowColor: Colors.black,
          elevation: 1,
          notchMargin: 12,
          height: 64,
          shape: const CircularNotchedRectangle(),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TabButton(
                  title: "Menu",
                  onTap: () {
                    if (selectTab != 0) {
                      print('Switching to MenuView');
                      selectTab = 0;
                      selectPageView = const MenuView();
                      setState(() {});
                    }
                  },
                  icon: "assets/img/tab_menu.png",
                  isSelected: selectTab == 0,
                ),
                TabButton(
                  title: "Offer",
                  onTap: () {
                    if (selectTab != 1) {
                      print('Switching to OfferView');
                      selectTab = 1;
                      selectPageView = const OfferView();
                      setState(() {});
                    }
                  },
                  icon: "assets/img/tab_offer.png",
                  isSelected: selectTab == 1,
                ),
                const SizedBox(
                  width: 40,
                  height: 40,
                ),
                TabButton(
                  title: "Profile",
                  onTap: () {
                    if (selectTab != 3) {
                      print('Switching to ProfileView');
                      selectTab = 3;
                      selectPageView = const ProfileView();
                      setState(() {});
                    }
                  },
                  icon: "assets/img/tab_profile.png",
                  isSelected: selectTab == 3,
                ),
                TabButton(
                  title: "More",
                  onTap: () {
                    if (selectTab != 4) {
                      print('Switching to MoreView');
                      selectTab = 4;
                      selectPageView = const MoreView();
                      setState(() {});
                    }
                  },
                  icon: "assets/img/tab_more.png",
                  isSelected: selectTab == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}