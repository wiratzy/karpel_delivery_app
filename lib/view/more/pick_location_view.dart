import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  LatLng _center = LatLng(-6.9, 107.6);
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
          desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _center = latLng;
        _pickedLocation = latLng;
      });

      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address =
              "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      }

      _mapController.move(latLng, 16);
    } catch (_) {}
  }

  Future<void> _handleTap(LatLng tappedPoint) async {
    setState(() => _pickedLocation = tappedPoint);
    final placemarks = await placemarkFromCoordinates(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      setState(() {
        _address =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      });
    }
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
    final response = await http.get(url);
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
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              zoom: 14.0,
              onTap: (tapPosition, point) => _handleTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_pickedLocation != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _pickedLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  )
                ]),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari lokasi...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              child: const Icon(Icons.my_location),
              onPressed: _getUserLocation,
            ),
          ),
          if (_address != null)
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_address!),
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
        ],
      ),
    );
  }
}
