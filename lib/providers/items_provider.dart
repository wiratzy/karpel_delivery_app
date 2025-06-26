import 'package:flutter/material.dart';
import 'package:kons2/models/home_model.dart'; // Pastikan path ini benar (berisi Item dan ItemCategory)
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/services/api_services.dart';

class ItemsProvider with ChangeNotifier {
  final ApiService _apiService;
  final AuthProvider _authProvider; // Gunakan AuthProvider untuk mendapatkan token

  ItemsProvider(this._apiService, this._authProvider) {
    _fetchInitialData(); // Panggil saat provider pertama kali diinisialisasi
  }

  List<Item> _items = [];
  List<ItemCategory> _categories = [];
  ItemCategory? _selectedCategory;
  String? _searchQuery;

  bool _isLoadingItems = false;
  // int _count = 0; // Variabel _count dihapus karena tidak digunakan secara benar untuk itemsCount
  bool _isLoadingCategories = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<Item> get items => _items;
  List<ItemCategory> get categories => _categories;
  ItemCategory? get selectedCategory => _selectedCategory;
  bool get isLoadingItems => _isLoadingItems;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get hasMoreItems => _hasMoreItems;

  // Method untuk mengambil data awal (kategori dan item pertama)
  Future<void> _fetchInitialData() async {
    // Memuat kategori terlebih dahulu
    await fetchItemCategories();
    // Lalu memuat item pertama kali
    await fetchItems(reset: true);
  }

  // Method untuk mengambil daftar kategori item
  Future<void> fetchItemCategories() async {
    if (_isLoadingCategories) return;
    _isLoadingCategories = true;

    // Pastikan untuk mendapatkan token sebelum memanggil API
    final token = _authProvider.token; // <--- Mengambil token dari AuthProvider.user
    if (token == null) {
      print('Token autentikasi tidak tersedia untuk memuat kategori item.');
      _isLoadingCategories = false;
      notifyListeners();
      return; // Keluar jika tidak ada token
    }

    notifyListeners(); // Notifikasi sebelum try-catch

    try {
      // Panggil _apiService.fetchItemCategories() dengan parameter 'token'
      _categories = await _apiService.fetchItemCategories(token: token); // <--- Perbaikan di sini
      // Tambahkan opsi "All Categories" di awal daftar
      // Untuk sementara, itemsCount diatur ke 0 karena tidak ada data total item dari API
      _categories.insert(0, ItemCategory(id: 0, name: "All Categories", image: "null", itemsCount: 0));
    } catch (e) {
      print('Error fetching item categories: $e');
      // Anda bisa set _error state atau tampilkan pesan error lain di sini
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Method untuk mengambil daftar item dengan filter dan pagination
  Future<void> fetchItems({bool reset = false}) async {
    if (_isLoadingItems) return; // Hindari double fetch
    if (!_hasMoreItems && !reset) return; // Jika tidak ada lagi item dan bukan reset

    if (reset) {
      _currentPage = 1;
      _items = []; // Kosongkan daftar item jika reset
      _hasMoreItems = true;
    }

    _isLoadingItems = true;
    notifyListeners();

    try {
      // Ambil token dari AuthProvider (konsisten dengan fetchItemCategories)
      final token = _authProvider.token; // <--- Perbaikan di sini: gunakan .user?.token
      if (token == null) {
        throw Exception('Authentication token not available. Please login.');
      }

      final result = await _apiService.fetchItems(
        token: token,
        page: _currentPage,
        limit: _itemsPerPage,
        categoryId: _selectedCategory?.id == 0 ? null : _selectedCategory?.id.toString(),
        searchQuery: _searchQuery,
      );

      final newItems = result['items'] as List<Item>;
      _items.addAll(newItems); // Tambahkan item baru
      _hasMoreItems = result['hasMore'] as bool;
      _currentPage++; // Siapkan untuk halaman berikutnya

    } catch (e) {
      print('Error fetching items: $e');
      // Anda bisa set _error state di sini
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  // Method untuk memilih kategori filter
  void selectCategory(ItemCategory? category) {
    if (_selectedCategory?.id != category?.id) {
      _selectedCategory = category;
      fetchItems(reset: true); // Reset dan muat ulang item dengan kategori baru
    }
  }

  // Method untuk menerapkan filter pencarian
  void applySearchFilter(String? query) {
    final trimmedQuery = query?.trim(); // Hapus spasi di awal/akhir

    // Hanya lakukan fetch jika query berubah
    if (_searchQuery != trimmedQuery) {
      _searchQuery = trimmedQuery;
      fetchItems(reset: true); // Reset dan muat ulang item dengan filter pencarian
    }
  }

  // Method untuk mereset filter pencarian (misal saat tombol 'X' ditekan)
  void resetSearchFilter() {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _searchQuery = null; // Hapus query pencarian
      // Tidak perlu fetch di sini, karena _fetchInitialData atau _clearSearch di view
      // akan memicu fetchItems lagi jika diperlukan.
    }
  }

  // Method untuk refresh data (tarik ke bawah)
  Future<void> refreshItems() async {
    _searchQuery = null;
    await fetchItemCategories(); // Refresh kategori juga
    await fetchItems(reset: true);
  }
}