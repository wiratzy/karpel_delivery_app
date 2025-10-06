import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  LatLng _center = LatLng(-6.914744, 107.609810); // Default: Alun-alun Bandung
  LatLng? _pickedLocation;
  String? _address;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  Future<void> _getUserLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _center = latLng;
        _pickedLocation = latLng;
      });

      await _reverseGeocode(latLng);
      _mapController.move(latLng, 16);
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'karpel_food_delivery_app/1.0',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _address = data['display_name'] ?? 'Alamat tidak ditemukan';
      });
    } else {
      setState(() {
        _address = 'Alamat tidak ditemukan';
      });
    }
  }

  Future<void> _handleTap(LatLng tappedPoint) async {
    setState(() => _pickedLocation = tappedPoint);
    await _reverseGeocode(tappedPoint);
  }

  void _confirmLocation() {
    if (_pickedLocation == null || _address == null) return;
    Navigator.pop(context, {
      'latitude': _pickedLocation!.latitude,
      'longitude': _pickedLocation!.longitude,
      'formatted_address': _address!,
    });
  }

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    final response = await http.get(url, headers: {
      'User-Agent': 'karpel_food_delivery_app/1.0',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final result = data[0];
        final lat = double.parse(result['lat']);
        final lon = double.parse(result['lon']);
        final latLng = LatLng(lat, lon);

        setState(() {
          _center = latLng;
          _pickedLocation = latLng;
          _address = result['display_name'];
        });
        _mapController.move(latLng, 16);
      } else {
        setState(() {
          _address = 'Lokasi tidak ditemukan';
        });
      }
    }
  }

  void _editAddressDialog() async {
  final controller = TextEditingController(text: _address);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Alamat"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Tulis alamat lengkap...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () {
              setState(() {
                _address = controller.text.trim();
              });
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}


  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Pilih Lokasi")),
      body: Stack(
        children: [
          SizedBox.expand(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _center,
                zoom: 14.0,
                onTap: (tapPosition, point) => _handleTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.karpel.food_delivery',
                  backgroundColor: Colors.grey[200],
                ),
                if (_pickedLocation != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _pickedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    )
                  ]),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari lokasi...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          ),
          
          Positioned(
            bottom: 200,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_address != null)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _address!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Gunakan Lokasi Ini"),
              onPressed: _confirmLocation,
            ),
          ),

           Positioned(
    bottom: 60,
    left: 20,
    right: 20,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text("Edit Alamat"),
      onPressed: _editAddressDialog,
    ),
  ),
        ],
      ),
    );
  }
}
