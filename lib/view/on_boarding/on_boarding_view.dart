import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _completeOnboarding(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOnboardingCompleted', true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setOnboardingCompleted(true);
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan status onboarding: $e')),
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
                          ? "Get Started"
                          : "Next",
                      onPressed: () async {
                        if (selectPage == pageArr.length - 1) {
                          await _completeOnboarding(context);
                        } else {
                          setState(() {
                            selectPage = selectPage + 1;
                            controller.animateToPage(
                              selectPage,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          });
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