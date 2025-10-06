import 'package:flutter/material.dart';

class ResponsiveStatusChip extends StatelessWidget {
  final String status;

  const ResponsiveStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Map warna status
    final Map<String, Color> statusColors = {
      'menunggu_konfirmasi': Colors.orange,
      'diproses': Colors.blue,
      'diantar': Colors.green,
      'dibatalkan': Colors.red,
      'berhasil': Colors.teal,
    };

    // Responsif font dan padding
    final double chipFontSize;
    final EdgeInsets chipPadding;

    if (screenWidth < 360) {
      chipFontSize = 10;
      chipPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 1);
    } else if (screenWidth < 480) {
      chipFontSize = 12;
      chipPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    } else {
      chipFontSize = 14;
      chipPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    }

    return Chip(
      label: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: chipFontSize,
        ),
      ),
      padding: chipPadding,
      backgroundColor: statusColors[status] ?? Colors.grey,
    );
  }
}
