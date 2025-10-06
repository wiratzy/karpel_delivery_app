import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:karpel_food_delivery/common_widget/round_textfield.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class ChangeAddressView extends StatefulWidget {
  const ChangeAddressView({super.key});

  @override
  _ChangeAddressViewState createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  LatLng _currentLocation = LatLng(-6.32639000, 108.32000000);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        _searchLocation(); // Trigger saat user selesai input
      }
    });
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        setState(() {
          _currentLocation = LatLng(
            locations[0].latitude,
            locations[0].longitude,
          );
        });
      }
    } catch (e) {
      print('Lokasi tidak ditemukan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat tidak ditemukan')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ubah Alamat")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _currentLocation,
                zoom: 15.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _currentLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 60.0,
                      height: 60.0,
                      point: _currentLocation,
                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: RoundTextfield(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: "Cari alamat...",
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    print("Lokasi dipilih: $_currentLocation");
                    // Navigator.pop(context, _currentLocation);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.download, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
