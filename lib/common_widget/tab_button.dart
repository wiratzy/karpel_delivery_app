import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';

class TabButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String icon;
  final bool isSelected;
  const TabButton(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 15,
            height: 15,
            color: isSelected ? Tcolor.primary : Tcolor.placeholder,
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            title,
            style: TextStyle(
                color: isSelected ? Tcolor.primary : Tcolor.placeholder,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
