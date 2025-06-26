import 'package:flutter/material.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DriverView extends StatelessWidget {
  const DriverView({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda ingin logout dan keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Driver Dashboard')),
        body: const Center(child: Text('Welcome to Driver Dashboard')),
      ),
    );
  }
}