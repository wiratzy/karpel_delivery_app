import 'dart:math'; // Diperlukan untuk 'min'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk TextInputFormatter
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/driver_model.dart';
import 'package:karpel_food_delivery/providers/owner_driver_provider.dart';
import 'package:provider/provider.dart';

class PlateNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '').toUpperCase();
    if (text.isEmpty) {
      return const TextEditingValue();
    }
    
    final buffer = StringBuffer();
    
    buffer.write(text.substring(0, min(1, text.length)));
    
    if (text.length > 1) {
      buffer.write(' ');
      buffer.write(text.substring(1, min(5, text.length)));
    }

    if (text.length > 5) {
      buffer.write(' ');
      buffer.write(text.substring(5, min(8, text.length)));
    }
    
    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class EditDriverView extends StatefulWidget {
  final Driver driver;

  const EditDriverView({super.key, required this.driver});

  @override
  State<EditDriverView> createState() => _EditDriverViewState();
}

class _EditDriverViewState extends State<EditDriverView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleNumberController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data driver yang ada
    _nameController = TextEditingController(text: widget.driver.name);
    _phoneController = TextEditingController(text: widget.driver.phone);
    _vehicleNumberController = TextEditingController(text: widget.driver.vehicleNumber);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final provider = Provider.of<OwnerDriverProvider>(context, listen: false);
        await provider.editDriver(widget.driver.id, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'vehicle_number': _vehicleNumberController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data driver berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Kembali dan beri sinyal sukses
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui data: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Informasi Driver'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Perbarui Informasi",
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
                  inputFormatters: [PlateNumberInputFormatter()], // Terapkan formatter
                  textCapitalization: TextCapitalization.characters,
                  validator: (val) => val == null || val.isEmpty ? 'Plat nomor wajib diisi' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Tcolor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
          ),
        ),
      ),
    );
  }
}