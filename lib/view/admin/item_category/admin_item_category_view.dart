import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/admin_item_category_model.dart';
import 'package:karpel_food_delivery/providers/admin_item_category_provider.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AdminItemCategoryView extends StatefulWidget {
  const AdminItemCategoryView({super.key});

  @override
  State<AdminItemCategoryView> createState() => _AdminItemCategoryViewState();
}

class _AdminItemCategoryViewState extends State<AdminItemCategoryView> {
  @override
  void initState() {
    super.initState();
    // Menggunakan addPostFrameCallback untuk memastikan context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // listen: false di initState
      Provider.of<AdminItemCategoryProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer agar widget hanya rebuild saat ada perubahan
    return Consumer<AdminItemCategoryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Tcolor.primary,
            foregroundColor: Colors.white,
            title: const Text('Kelola Kategori Item'),
            centerTitle: true,
            elevation: 1,
          ),
          body: Skeletonizer(
            enabled: provider.isLoading,
            child: RefreshIndicator(
              onRefresh: () => provider.init(),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: provider.isLoading ? 8 : provider.categories.length,
                itemBuilder: (context, index) {
                  // Saat loading, kita buat data palsu agar skeletonizer bisa menggambar
                  final category = provider.isLoading
                      ? AdminItemCategory(id: 0, name: 'Loading Category...', image: '')
                      : provider.categories[index];
                  return _buildCategoryCard(context, provider, category);
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Tcolor.primary,
            foregroundColor: Colors.white,
            onPressed: () => _openFormDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text("Tambah"),
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan setiap kategori dalam bentuk Card
  Widget _buildCategoryCard(BuildContext context, AdminItemCategoryProvider provider, AdminItemCategory category) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            category.image ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade200,
              child: Icon(Icons.category, color: Colors.grey.shade400),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
              onPressed: () => _openFormDialog(context, provider, isEdit: true, category: category),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              onPressed: () => _showDeleteConfirmation(context, provider, category),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi sebelum menghapus
  void _showDeleteConfirmation(BuildContext context, AdminItemCategoryProvider provider, AdminItemCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCategory(category.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Tcolor.primary),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog untuk form tambah/edit
  void _openFormDialog(BuildContext context, AdminItemCategoryProvider provider, {bool isEdit = false, AdminItemCategory? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    File? pickedImage;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving, // Mencegah dialog ditutup saat sedang menyimpan
      builder: (ctx) {
        // StatefulBuilder agar UI di dalam dialog bisa di-update (untuk image preview)
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Area untuk preview gambar
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            pickedImage = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: pickedImage != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(pickedImage!, fit: BoxFit.cover))
                            : (category?.image != null && category!.image!.isNotEmpty)
                                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(category.image!, fit: BoxFit.cover))
                                : const Center(child: Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_important_outline),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    final body = {'name': nameController.text.trim()};
                    
                    try {
                      if (isEdit && category != null) {
                        await provider.editCategory(category.id, body, pickedImage);
                      } else {
                        await provider.addCategory(body, pickedImage);
                      }
                      if (mounted) Navigator.of(ctx).pop();
                    } catch (e) {
                      // Tampilkan error jika ada
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
                      );
                    } finally {
                       if (mounted) {
                         setDialogState(() => isSaving = false);
                       }
                    }
                  },
                  child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }
}