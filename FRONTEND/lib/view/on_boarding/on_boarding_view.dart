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
        // Pastikan page tidak null sebelum menggunakan .round()
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.completeOnboarding();

      if (!mounted) return;
      // Navigasi ke halaman utama setelah onboarding selesai
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
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
        backgroundColor: Colors.white, // Latar belakang putih untuk tampilan bersih
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: pageArr.length,
                onPageChanged: (index) { // Tambahkan onPageChanged untuk update selectPage
                  setState(() {
                    selectPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  var pObj = pageArr[index] as Map? ?? {};
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten vertikal
                    children: [
                      // Bagian Gambar
                      Container(
                        height: media.height * 0.40, // Sesuaikan tinggi gambar
                        width: media.width,
                        alignment: Alignment.center,
                        child: Image.asset(
                          pObj["image"].toString(),
                          width: media.width * 0.8, // Sesuaikan lebar gambar
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Spacer untuk memberikan ruang fleksibel
                      const Spacer(), 

                      // Bagian Teks Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30), // Padding lebih besar
                        child: Text(
                          pObj["title"].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Tcolor.primaryText,
                            fontSize: 28, // Ukuran font lebih besar untuk judul
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15), // Jarak antara title dan subtitle
                      
                      // Bagian Teks Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30), // Padding lebih besar
                        child: Text(
                          pObj["subtitle"].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Tcolor.secondaryText,
                            fontSize: 16, // Ukuran font subtitle
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const Spacer(), // Spacer lagi untuk menekan konten ke atas sedikit
                    ],
                  );
                },
              ),
              
              // Posisi Indikator dan Tombol di Bawah
              Positioned(
                bottom: media.height * 0.05, // Sesuaikan posisi dari bawah
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pageArr.asMap().entries.map((entry) {
                        var index = entry.key;
                        return AnimatedContainer( // Gunakan AnimatedContainer untuk transisi halus
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5), // Jarak antar dot
                          height: 8, // Tinggi dot
                          width: index == selectPage ? 20 : 8, // Lebar dot yang aktif lebih panjang
                          decoration: BoxDecoration(
                            color: index == selectPage
                                ? Tcolor.primary // Warna aktif
                                : Tcolor.placeholder, // Warna tidak aktif
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30), // Jarak antara dots dan tombol
                    
                    // Tombol
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25), // Padding horizontal untuk tombol
                      child: RoundButton(
                        title: selectPage == pageArr.length - 1
                            ? "Mulai Sekarang"
                            : "Selanjutnya",
                        onPressed: () {
                          if (selectPage == pageArr.length - 1) {
                            _completeOnboarding();
                          } else {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
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