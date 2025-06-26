import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:kons2/providers/auth_provider.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  static const double allowedLatitude = -6.327;
  static const double allowedLongitude = 108.323;
  static const double allowedRadiusInMeters = 25000; // 20 km

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AuthProvider>(context, listen: false).init();
      checkUserLocation();
    });
  }

  void checkUserLocation() async {
    try {
      bool allowed = await isUserInAllowedArea();

      if (!allowed) {
        _showLocationBlockedDialog();
        return;
      }

      await Future.delayed(const Duration(seconds: 2));
      goNextPage();
    } catch (e) {
      _showErrorDialog("Gagal mendeteksi lokasi.\nPastikan GPS diaktifkan.");
    }
  }

  Future<bool> isUserInAllowedArea() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = Geolocator.distanceBetween(
      allowedLatitude,
      allowedLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= allowedRadiusInMeters;
  }

  void goNextPage() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      if (auth.user?.role == 'customer' && !auth.isOnboardingCompleted) {
        Navigator.pushReplacementNamed(context, '/onBoarding');
      } else {
        switch (auth.user?.role) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin');
            break;
          case 'restaurant_owner':
            Navigator.pushReplacementNamed(context, '/restaurantOwner');
            break;
          case 'driver':
            Navigator.pushReplacementNamed(context, '/driver');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _showLocationBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: const [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 10),
              Text("Wilayah Tidak Didukung"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Aplikasi ini hanya dapat digunakan oleh pengguna yang berada di dalam wilayah operasional.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kesalahan Lokasi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/img/splash_bg.png",
              width: media.width,
              height: media.height,
              fit: BoxFit.cover,
            ),
            Image.asset(
              "assets/img/app_logo.png",
              width: media.width * 0.55,
              height: media.width * 0.55,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
