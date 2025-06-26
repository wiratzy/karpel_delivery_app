import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp/1.0' // wajib ya, biar ga di-block
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'];
    } else {
      return null;
    }
  }
}
