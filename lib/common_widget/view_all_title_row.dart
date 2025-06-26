import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';

class ViewAllTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  const ViewAllTitleRow({super.key, required this.title, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
            style: TextStyle(
                color: Tcolor.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        TextButton(
          onPressed: onView,
          child: Text("view all",
              style: TextStyle(
                  color: Tcolor.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        )
      ],
    );
  }
}
