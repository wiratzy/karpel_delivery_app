import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpel_food_delivery/common/color_extension.dart'; // <-- Pastikan ini diimpor
import 'package:karpel_food_delivery/models/admin_restaurant_model.dart';
import 'package:karpel_food_delivery/providers/admin_restaurant_provider.dart'; // <-- Pastikan ini diimpor
import 'package:provider/provider.dart'; // <-- Pastikan ini diimpor

class AdminRestaurantFormView extends StatefulWidget {
  final AdminRestaurant? restaurant;

  const AdminRestaurantFormView({super.key, this.restaurant});

  @override
  State<AdminRestaurantFormView> createState() =>
      _AdminRestaurantFormViewState();
}

class _AdminRestaurantFormViewState extends State<AdminRestaurantFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final picker = ImagePicker();

  File? _image;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _typeController = TextEditingController();
  final _foodTypeController = TextEditingController();

  // Variabel isEdit harus didefinisikan di dalam State class
  late bool isEdit; // Menggunakan late karena akan diinisialisasi di initState

  @override
  void initState() {
    super.initState();
    isEdit = widget.restaurant != null; // Inisialisasi isEdit di initState

    final r = widget.restaurant;
    if (r != null) {
      _nameController.text = r.name;
      _locationController.text = r.location ?? '';
      _emailController.text = r.owner?.email ?? ''; // Ambil email dari owner
      _phoneController.text = r.phone?.toString() ?? ''; // Ambil phone dari owner
      _typeController.text = r.type ?? '';
      _foodTypeController.text = r.foodType ?? '';
      // Password tidak diisi saat edit karena tidak dikirim dari API
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _typeController.dispose();
    _foodTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Perbaikan: Pastikan Provider diimpor dan AdminRestaurantProvider bisa diakses
    final provider =
        Provider.of<AdminRestaurantProvider>(context, listen: false);

    final Map<String, String> body = {
      'name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'type': _typeController.text.trim(),
      'food_type': _foodTypeController.text.trim(),
    };

    // Password hanya ditambahkan jika tidak dalam mode edit atau jika diisi saat edit
    if (!isEdit || _passwordController.text.isNotEmpty) {
      body['password'] = _passwordController.text.trim();
    }

    try {
      if (widget.restaurant == null) {
        await provider.addRestaurant(body, _image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restoran berhasil ditambahkan"), backgroundColor: Colors.green),
          );
        }
      } else {
        await provider.editRestaurant(widget.restaurant!.id, body, _image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restoran berhasil diperbarui"), backgroundColor: Colors.green),
          );
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Pop dengan true untuk refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Restoran" : "Tambah Restoran"),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Tcolor.textfield, // <-- Tcolor seharusnya sudah dikenali
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Tcolor.secondaryText.withOpacity(0.5)), // <-- Tcolor seharusnya sudah dikenali
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      : (widget.restaurant?.image != null
                          ? Image.network(
                              widget.restaurant!.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: Icon(Icons.broken_image, size: 70, color: Colors.grey[400]),
                                  ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Tcolor.secondaryText), // <-- Tcolor seharusnya sudah dikenali
                                const SizedBox(height: 8),
                                Text("Pilih Gambar Restoran", style: TextStyle(color: Tcolor.secondaryText)), // <-- Tcolor seharusnya sudah dikenali
                              ],
                            )),
                ),
              ),
              const SizedBox(height: 20),

              // Text Fields
              _buildTextField(_nameController, "Nama Restoran", 'name'),
              _buildTextField(_emailController, "Email", 'email', keyboardType: TextInputType.emailAddress, isEmail: true),
              _buildTextField(
                _passwordController,
                "Password",
                'password',
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Tcolor.secondaryText, // <-- Tcolor seharusnya sudah dikenali
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                isRequired: !isEdit,
              ),
              _buildTextField(_locationController, "Lokasi (Alamat Lengkap)", 'location'),
              _buildTextField(_phoneController, "No. Telepon", 'phone', keyboardType: TextInputType.phone, isRequired: false),
              _buildTextField(_typeController, "Tipe Restoran (contoh: Cafe, Warteg)", 'type'),
              _buildTextField(_foodTypeController, "Jenis Makanan (contoh: Padang, Sunda)", 'food_type'),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  isEdit ? "Update Restoran" : "Simpan Restoran",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Tcolor.primary, // <-- Tcolor seharusnya sudah dikenali
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String fieldName, {
    bool obscureText = false,
    Widget? suffixIcon,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Tcolor.secondaryText), // <-- Tcolor seharusnya sudah dikenali
          filled: true,
          fillColor: Tcolor.textfield, // <-- Tcolor seharusnya sudah dikenali
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Tcolor.placeholder.withOpacity(0.5), width: 1), // <-- Tcolor seharusnya sudah dikenali
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Tcolor.primary, width: 2), // <-- Tcolor seharusnya sudah dikenali
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          if (isEmail && value != null && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Format email tidak valid';
          }
          if (fieldName == 'phone' && value != null && value.isNotEmpty) {
            final RegExp indoPhoneRegex = RegExp(r'^(08\d{8,11}|\+628\d{8,11})$');
            if (!indoPhoneRegex.hasMatch(value)) {
              return 'Format nomor telepon tidak valid. Gunakan 08xx atau +628xx.';
            }
          }
          return null;
        },
      ),
    );
  }
}