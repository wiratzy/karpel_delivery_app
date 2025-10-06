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
                errorBuilder: (context, error, stackTrace) {
                  print('Image load error for ${cObj.name}: $error');
                  return const Icon(
                    Icons.broken_image, // Ikon standar untuk gambar rusak
                    color: Colors
                        .grey, // Beri warna abu-abu agar terlihat seperti placeholder
                    size:
                        85, // Sesuaikan ukurannya agar sama dengan gambar asli
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
