import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common_widget/round_button.dart';

import '../../common/color_extension.dart';

class CheckoutMessageView extends StatefulWidget {
  // final VoidCallback onSend; // Tambahkan ini

  // const CheckoutMessageView({super.key, required this.onSend});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      width: media.width,
      decoration: BoxDecoration(
          color: Tcolor.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Tcolor.primaryText,
                  size: 25,
                ),
              )
            ],
          ),
          Image.asset(
            "assets/img/thank_you.png",
            width: media.width * 0.55,
          ),
          const SizedBox(height: 25),
          Text(
            "Thank You!",
            style: TextStyle(
                color: Tcolor.primaryText,
                fontSize: 26,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "for your order",
            style: TextStyle(
                color: Tcolor.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 25),
          Text(
            "Your Order is now being processed. We will let you know once the order is picked from the outlet. Check the status of your Order",
            textAlign: TextAlign.center,
            style: TextStyle(color: Tcolor.primaryText, fontSize: 14),
          ),
          const SizedBox(height: 35),

          /// GANTI di sini
          RoundButton(
            title: "Track My Order",
            onPressed: () {
            },
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Back To Home",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Tcolor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
