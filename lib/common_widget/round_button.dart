import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';


enum RoundButtonType{ bgPrimary, textPrimary }
class RoundButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final RoundButtonType type;
  final double fontSize;
  const RoundButton({super.key, required this.title, required this.onPressed,  this.type = RoundButtonType.bgPrimary,  this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: type == RoundButtonType.bgPrimary ? null : Border.all(color: Tcolor.primary, width: 1),
          color: type == RoundButtonType.bgPrimary ? Tcolor.primary : Tcolor.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          title,
          style: TextStyle(
              color: type == RoundButtonType.bgPrimary ? Tcolor.white : Tcolor.primary, fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
