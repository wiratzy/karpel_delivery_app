import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MostPopularCell extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MostPopularCell({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                mObj["image"].toString(),
                width: 240,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              mObj["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Tcolor.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(mObj["type"] ?? "unkown type",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Tcolor.primaryText, fontSize: 12)),
                Text(
                  " . ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Tcolor.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  mObj["location"] ?? "unkown type",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Tcolor.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 8,),
                Image.asset(
                  "assets/img/rate.png",
                  width: 10,
                  height: 10,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 4,),
                Text(
                  mObj["rate"] ?? "unkown type",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Tcolor.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
