import 'dart:math'; // Diperlukan untuk 'min'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk TextInputFormatter
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/providers/owner_driver_provider.dart';
import 'package:provider/provider.dart';

// LANGKAH 1: Buat custom formatter untuk plat nomor
class PlateNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Ambil teks, hapus spasi, dan ubah menjadi huruf besar
    final text = newValue.text.replaceAll(' ', '').toUpperCase();
    if (text.isEmpty) {
      return const TextEditingValue();
    }
    
    // 2. Buat buffer untuk membangun string yang diformat
    final buffer = StringBuffer();
    
    // 3. Logika pemformatan "E 1234 ABC"
    // Huruf pertama (Kode Wilayah)
    buffer.write(text.substring(0, min(1, text.length)));
    
    // Angka (hingga 4 digit)
    if (text.length > 1) {
      buffer.write(' ');
      buffer.write(text.substring(1, min(5, text.length)));
    }

    // Huruf akhir (hingga 3 karakter)
    if (text.length > 5) {
      buffer.write(' ');
      buffer.write(text.substring(5, min(8, text.length)));
    }
    
    // 4. Kembalikan nilai yang sudah diformat
    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}


class CreateDriverView extends StatefulWidget {
  const CreateDriverView({super.key});

  @override
  State<CreateDriverView> createState() => _CreateDriverViewState();
}

class _CreateDriverViewState extends State<CreateDriverView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  bool _isLoading = false; // State untuk loading indicator

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Mulai loading
      try {
        final provider = Provider.of<OwnerDriverProvider>(context, listen: false);
        await provider.addDriver({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'vehicle_number': _vehicleNumberController.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver berhasil ditambahkan!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Kembali dan beri sinyal sukses
        }
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan driver: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false); // Hentikan loading
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Driver Baru'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Dibuat scrollable
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
                "Informasi Driver",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Driver',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Nomor telepon wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plat Nomor',
                  hintText: 'Contoh: E 1234 ABC',
                  prefixIcon: Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                // LANGKAH 2: Terapkan formatter
                inputFormatters: [PlateNumberInputFormatter()],
                textCapitalization: TextCapitalization.characters,
                 validator: (val) => val == null || val.isEmpty ? 'Plat nomor wajib diisi' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit, // Nonaktifkan saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Tcolor.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                    : const Text('Simpan Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}