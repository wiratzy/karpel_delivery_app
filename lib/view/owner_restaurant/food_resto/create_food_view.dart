import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/providers/create_item_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:provider/provider.dart';

class CreateItemView extends StatefulWidget {
  const CreateItemView({super.key});

  @override
  State<CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<CreateItemView> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  List<ItemCategory> categories = [];
  bool isCategoryLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isCategoryLoading = true);
    try {
      final token = await StorageService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final result = await ApiService().fetchItemCategories(token: token);
      setState(() {
        categories = result;
      });
    } catch (e) {
      print('❌ Gagal ambil kategori: $e');
    } finally {
      setState(() => isCategoryLoading = false);
    }
  }

  File? _imageFile;

  // Form fields
  String name = '';
  double? rate;
  String? rating;
  String type = '';
  String? location;
  double? price;
  int? categoryId;

  bool isLoading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await StorageService().getToken();
    final user = await StorageService().getUser();

    final restaurantId = user?.restaurantId;
    print('🧠 User JSON: ${user?.toJson()}');


    print('DEBUG: token = $token');
    print('DEBUG: restaurantId = $restaurantId');

    if (token == null || restaurantId == null) {
      print('⛔ GAGAL karena token / restaurantId null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Autentikasi gagal: token=$token, restaurantId=$restaurantId')),
      );
      return;
    }

    _formKey.currentState!.save();

    final data = {
      'name': name,
      'rate': rate?.toString(),
      'type': type,
      'price': price?.toString(),
      'item_category_id': categoryId?.toString(),
      'restaurant_id': restaurantId.toString(),
    };

    final provider = Provider.of<CreateItemProvider>(context, listen: false);

    final success = await provider.createItem(
      token: token,
      data: data,
      imageFile: _imageFile,
    );

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Berhasil'),
          content:
              const Text('Menu makanan berhasil ditambahkan ke restoran Anda.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pushReplacementNamed(context, '/restoFoodInfo');
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal menyimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: _imageFile == null
                      ? const Center(child: Text('Pilih Gambar'))
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Item'),
                onSaved: (val) => name = val ?? '',
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tipe'),
                onSaved: (val) => type = val ?? '',
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                onSaved: (val) => price = double.tryParse(val ?? ''),
              ),
              isCategoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      value: categoryId,
                      items: categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          categoryId = val;
                        });
                      },
                    ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle:
                            const TextStyle(fontSize: 16, color: Colors.white),
                        backgroundColor: Tcolor.primary,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
