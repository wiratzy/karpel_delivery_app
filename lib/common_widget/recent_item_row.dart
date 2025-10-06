import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/cofing.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/home_model.dart'; // Impor kelas Item

class RecentItemRow extends StatelessWidget {
  final Item rObj; // Ubah dari Map menjadi Item
  final VoidCallback onTap;

  const RecentItemRow({super.key, required this.rObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                rObj.image, // Gunakan getter imageUrl dari Item
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Image load error for ${rObj.name}: $error');
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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    rObj.name,
                    textAlign: TextAlign.start, // Ubah dari center ke start
                    style: TextStyle(
                      color: Tcolor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          rObj.type ?? "Unknown type",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Tcolor.primaryText,
                            fontSize: 11,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Potong teks panjang
                        ),
                      ),
                      Text(
                        " . ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Tcolor.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          formatPrice(rObj.price),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Tcolor.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Potong teks panjang
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/img/rate.png",
                        width: 10,
                        height: 10,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rObj.rate ?? "0.0",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Tcolor.primary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${rObj.rating} Ratings)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Tcolor.secondaryText,
                          fontSize: 11,
                        ),
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
