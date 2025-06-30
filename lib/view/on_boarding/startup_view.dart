import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'dart:io'; // Diperlukan untuk keluar dari aplikasi

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  static const double allowedLatitude = -6.327;
  static const double allowedLongitude = 108.323;
  static const double allowedRadiusInMeters = 25000; // 25 km

  @override
  void initState() {
    super.initState();
    // Panggil satu fungsi utama yang mengurus semuanya.
    _initializeAndNavigate();
  }

  /// Fungsi utama yang mengurus semua proses saat startup:
  /// 1. Memuat sesi pengguna (token & user data).
  /// 2. Memeriksa izin dan lokasi pengguna.
  /// 3. Menentukan halaman selanjutnya berdasarkan status login dan role.
  Future<void> _initializeAndNavigate() async {
    // Menunggu frame pertama selesai di-render untuk memastikan context valid.
    await WidgetsBinding.instance.endOfFrame;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Muat sesi pengguna dari storage. AuthProvider akan tahu siapa pengguna saat ini.
      await authProvider.init();

      // 2. Periksa apakah pengguna berada di dalam area yang diizinkan.
      //    Jika tidak, tampilkan dialog dan hentikan proses.
      bool isAllowed = await isUserInAllowedArea();
      if (!isAllowed) {
        _showLocationBlockedDialog();
        return; 
      }

      // 3. Panggil logika navigasi yang sudah benar dan terpusat.
      _navigateBasedOnAuthState(authProvider);

    } catch (e) {
      // Tangani semua kemungkinan error (misal: GPS mati, izin ditolak, dll).
      _showErrorDialog("Gagal memulai aplikasi: ${e.toString()}");
    }
  }

  /// Logika navigasi yang terpusat dan tidak ambigu.
  /// Fungsi ini adalah satu-satunya yang memutuskan "ke mana harus pergi".
  void _navigateBasedOnAuthState(AuthProvider auth) {
    if (!mounted) return;

    // KONDISI 1: Pengguna sudah login dan datanya ada.
    if (auth.isLoggedIn && auth.user != null) {
      final userRole = auth.user!.role;

      // Tentukan halaman berdasarkan role.
      switch (userRole) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 'restaurant_owner':
          Navigator.pushReplacementNamed(context, '/restaurantOwner');
          break;
        case 'driver':
          Navigator.pushReplacementNamed(context, '/driver');
          break;
        
        case 'customer':
          // BENAR: Pengecekan onboarding HANYA ada di dalam case 'customer'.
          if (auth.isOnboardingCompleted) {
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            Navigator.pushReplacementNamed(context, '/onBoarding');
          }
          break;
          
        default:
          // Jika role tidak dikenal, anggap sesi tidak valid.
          Navigator.pushReplacementNamed(context, '/welcome');
      }
    } 
    // KONDISI 2: Pengguna TIDAK login.
    else {
      // Langsung arahkan ke halaman welcome/login.
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  /// Memeriksa izin dan menghitung jarak lokasi pengguna.
  Future<bool> isUserInAllowedArea() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Layanan lokasi (GPS) tidak aktif.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Harap aktifkan melalui pengaturan aplikasi.');
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

  // --- WIDGET DIALOG UNTUK UMPAN BALIK PENGGUNA ---

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
          content: const Text(
            "Mohon maaf, aplikasi ini hanya dapat digunakan di dalam wilayah operasional kami.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => exit(0), 
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Terjadi Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeAndNavigate();
            },
            child: const Text("Coba Lagi"),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Selama proses inisialisasi, tampilkan splash screen.
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/img/splash_bg.png",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            Image.asset(
              "assets/img/app_logo.png",
              width: MediaQuery.of(context).size.width * 0.55,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
