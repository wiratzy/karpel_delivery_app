import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/cofing.dart';
import 'package:karpel_food_delivery/models/home_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/services/storage_services.dart';
import 'package:karpel_food_delivery/view/owner_restaurant/food_resto/edit_food_view.dart';

class DetailFoodView extends StatefulWidget {
  final Item item;

  const DetailFoodView({super.key, required this.item});

  @override
  State<DetailFoodView> createState() => _DetailFoodViewState();
}

class _DetailFoodViewState extends State<DetailFoodView> {
  late Item _item;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _refreshItem() async {
    try {
      final token = await StorageService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final itemDetail = await ApiService().fetchItemDetail(
        token: token,
        itemId: _item.id,
      );

      setState(() {
        _item = itemDetail;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ulang item: $e')),
      );
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah kamu yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);

      final token = await StorageService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      await ApiService().deleteItem(token: token, itemId: _item.id);

      if (!mounted) return;
      Navigator.pop(context, true); // kembali ke daftar dan trigger refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus item: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditFoodView(item: _item),
                ),
              );

              // Jika edit berhasil (return true), refresh data
              if (updated == true) {
                await _refreshItem();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteItem();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshItem,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // penting agar RefreshIndicator bisa dipicu meski scroll sedikit
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _item.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Nama & Harga
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _item.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                _item.price != null ? formatPrice(_item.price) : '-',
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),

              const SizedBox(height: 12),

              // Kategori
              if (_item.itemCategory != null)
                Row(
                  children: [
                    const Icon(Icons.category, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _item.itemCategory!.name,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Tipe
              if (_item.type.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.label, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Tipe: ${_item.type}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),

              const SizedBox(height: 12),

              // Rating
              if ((_item.rating != 0) || (_item.rate.isNotEmpty))
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Rating: ${_item.rate} (${_item.rating})',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
