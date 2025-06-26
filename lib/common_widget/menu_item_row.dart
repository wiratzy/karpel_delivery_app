import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MenuItemRow extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MenuItemRow({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(
              mObj["image"].toString(),
              width: double.maxFinite,
              height: 200,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.maxFinite,
              height: 200,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.transparent
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        mObj["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Tcolor.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/img/rate.png",
                            width: 10,
                            height: 10,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            mObj["rate"] ?? "unkown type",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Tcolor.primary,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            mObj["type"] ?? "unkown type",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Tcolor.white, fontSize: 11),
                          ),
                          Text(
                            " . ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Tcolor.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            mObj["food_type"] ?? "unkown type",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Tcolor.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
