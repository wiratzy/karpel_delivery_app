import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class PopularRestaurantRow extends StatelessWidget {
  final Map pObj;
  final VoidCallback onTap;
  const PopularRestaurantRow({super.key, required this.pObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Image.network(
                pObj["image"].toString() ,
                width: double.maxFinite,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(
              width: 8,
            ),

            SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      pObj["name"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Tcolor.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 8,
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
                        SizedBox(width: 4,),
                        Text(
                          pObj["rate"] ?? "unkown type",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Tcolor.primary,
                              fontSize: 11,),
                        ),
              
                        SizedBox(width: 8,),
                        Text(
                          "(${  pObj["rating"] } Ratings)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Tcolor.secondaryText,
                              fontSize: 11,),
                        ),
                        SizedBox(width: 8,),
                        Text(
                          pObj["type"] ?? "unkown type",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Tcolor.primaryText, fontSize: 11),
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
                          pObj["food_type"] ?? "unkown type",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Tcolor.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      
                      ],
                    ),
                 
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
