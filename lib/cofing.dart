import 'package:intl/intl.dart';

// final String baseUrl = "http://192.168.239.220:8000";
  // final  String baseUrl = 'http://172.20.10.2:8000'; 
  final  String baseUrl = 'http://192.168.1.120';

String formatPrice(String? rawPrice) {
  if (rawPrice == null || rawPrice.isEmpty) return 'Rp 0';

  try {
    final clean = rawPrice.replaceAll(',', '').replaceAll('.00', '');
    final double price = double.tryParse(clean) ?? 0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return formatter.format(price);
  } catch (e) {
    return 'Rp 0';
  }
}
