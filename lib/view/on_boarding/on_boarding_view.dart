import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/round_button.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  List pageArr = [
    {
      "title": "Cari Makanan Yang Kamu Suka",
      "subtitle": "Temukan Rasa Favoritmu di Sini!",
      "image": "assets/img/on_boarding_1.png"
    },
    {
      "title": "Fast Delivery",
      "subtitle": "Pengantaran Kilat untuk Kelezatan Instan",
      "image": "assets/img/on_boarding_2.png"
    },
    {
      "title": "Live Tracking",
      "subtitle": "Pelacakan secara real time",
      "image": "assets/img/on_boarding_3.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// **FUNGSI YANG SUDAH DIPERBAIKI**
  /// Fungsi ini sekarang hanya berinteraksi dengan AuthProvider.
  Future<void> _completeOnboarding() async {
    try {
      // 1. Dapatkan instance AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 2. Panggil fungsi yang benar dari provider.
      // Fungsi ini akan mengurus update state dan penyimpanan ke storage.
      await authProvider.completeOnboarding();

      // 3. Pastikan widget masih ada sebelum navigasi (best practice)
      if (!mounted) return;

      // 4. Arahkan pengguna ke halaman utama
      Navigator.pushReplacementNamed(context, '/main');

    } catch (e) {
      // Jika terjadi error, tampilkan pesan
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan onboarding: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false, // Mencegah tombol back
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: pageArr.length,
                itemBuilder: (context, index) {
                  var pObj = pageArr[index] as Map? ?? {};
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: media.height * 0.45,
                        width: media.width,
                        alignment: Alignment.center,
                        child: Image.asset(
                          pObj["image"].toString(),
                          width: media.width * 0.7,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          pObj["title"].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Tcolor.primaryText,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          pObj["subtitle"].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Tcolor.secondaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pageArr.asMap().entries.map((entry) {
                        var index = entry.key;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: index == selectPage ? 12 : 6,
                          decoration: BoxDecoration(
                            color: index == selectPage
                                ? Tcolor.primary
                                : Tcolor.placeholder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    RoundButton(
                      title: selectPage == pageArr.length - 1
                          ? "Mulai Sekarang"
                          : "Selanjutnya",
                      onPressed: () {
                        if (selectPage == pageArr.length - 1) {
                          // Panggil fungsi yang sudah diperbaiki
                          _completeOnboarding();
                        } else {
                          // Logika untuk pindah ke halaman selanjutnya
                          controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
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
}
