import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/models/home_model.dart';

import '../common/color_extension.dart';

class CategoryCell extends StatelessWidget {
  final ItemCategory cObj;
  final VoidCallback onTap;
  const CategoryCell({super.key, required this.cObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                cObj.image,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Image load error for ${cObj.name}: $error');
                  return Image.asset(
                    'assets/img/default_category.png', // Pastikan aset ini ada
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              cObj.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Tcolor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
