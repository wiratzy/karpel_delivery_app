import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/providers/edit_item_provider.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:provider/provider.dart';

class EditFoodView extends StatefulWidget {
  final Item item;

  const EditFoodView({super.key, required this.item});

  @override
  State<EditFoodView> createState() => _EditFoodViewState();
}

class _EditFoodViewState extends State<EditFoodView> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _imageFile;
  List<ItemCategory> categories = [];
  bool isCategoryLoading = false;

  // Form values
  late String name;
  late String type;
  late double price;
  int? categoryId;

  @override
  void initState() {
    super.initState();
    name = widget.item.name;
    type = widget.item.type;
    price = double.tryParse(widget.item.price ?? '0.0') ?? 0.0;
    categoryId = widget.item.itemCategoryId;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isCategoryLoading = true);
    try {
      final token = await StorageService().getToken();
      final result = await ApiService().fetchItemCategories(token: token!);
      setState(() {
        categories = result;
      });
    } catch (e) {
      print('❌ Gagal ambil kategori: $e');
    } finally {
      setState(() => isCategoryLoading = false);
    }
  }

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
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan')),
      );
      return;
    }

    _formKey.currentState!.save();

    final data = {
      'name': name,
      'type': type,
      'price': price.toString(),
      'item_category_id': categoryId?.toString(),
    };

    final provider = Provider.of<EditItemProvider>(context, listen: false);

    final success = await provider.updateItem(
      token: token,
      itemId: widget.item.id,
      data: data,
      imageFile: _imageFile,
    );

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Item berhasil diperbarui.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context, true); // Balik dan trigger refresh
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
    final provider = Provider.of<EditItemProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubah Data Makanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Tcolor.primary,
      ),
      body: Stack(
        children: [
          Padding(
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
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : Image.network(widget.item.image, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Nama Item'),
                    onSaved: (val) => name = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Tipe'),
                    onSaved: (val) => type = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    initialValue: price.toString(),
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => price = double.tryParse(val ?? '') ?? 0.0,
                    validator: (val) {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Harga harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  isCategoryLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          decoration:
                              const InputDecoration(labelText: 'Kategori'),
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
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _submit,
                    child: const Text('Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Tcolor.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
