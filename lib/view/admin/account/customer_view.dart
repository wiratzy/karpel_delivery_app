import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/user_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/view/admin/account/customer_detail_view.dart';
import 'package:provider/provider.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _token = Provider.of<AuthProvider>(context, listen: false).token;
      if (_token != null) {
        _fetchUsers();
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token autentikasi tidak ditemukan. Mohon login ulang.')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (_token == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final users = await _apiService.getAllUsers(_token!);
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        print('Error fetching users: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $e')),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _showDeleteConfirmationDialog(User user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda yakin ingin menghapus pengguna "${user.name}"?'),
                const Text('Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: Tcolor.secondaryText)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteUser(user.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(int userId) async {
    if (_token == null) return;
    try {
      await _apiService.deleteUser(_token!, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
      _fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengguna: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Customer'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Customer...',
                  filled: true,
                  fillColor: Tcolor.textfield,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Tcolor.secondaryText),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _filterUsers,
              ),
            ),
            // List of Users
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Tcolor.primary))
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            "Tidak ada customer ditemukan.",
                            style: TextStyle(color: Tcolor.secondaryText, fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchUsers,
                          color: Tcolor.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Card(
                                elevation: 3,
                                color: Tcolor.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Tcolor.primary.withOpacity(0.1),
                                    child: user.photo != null && Uri.tryParse(user.photo!)?.hasAbsolutePath == true
                                        ? ClipOval(
                                            child: Image.network( // Menggunakan Image.network langsung
                                              user.photo!,
                                              fit: BoxFit.cover,
                                              width: 56, // Diameter CircleAvatar
                                              height: 56, // Diameter CircleAvatar
                                              errorBuilder: (context, error, stackTrace) {
                                                // Fallback: Tampilkan Icon(Icons.person) jika gambar gagal dimuat
                                                return Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Tcolor.secondaryText.withOpacity(0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.person, color: Tcolor.secondaryText, size: 30),
                                                );
                                              },
                                            ),
                                          )
                                        : (user.name.isNotEmpty
                                            ? Text(
                                                user.name[0].toUpperCase(),
                                                style: TextStyle(
                                                    color: Tcolor.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              )
                                            : Icon(Icons.person, color: Tcolor.primary, size: 30)), // Fallback jika nama kosong juga
                                  ),
                                  title: Text(
                                    user.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Tcolor.primaryText,
                                    ),
                                  ),
                                  subtitle: Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Tcolor.secondaryText,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ### TOMBOL EDIT ###
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Tcolor.secondaryText),
                                        onPressed: () {
                                          print('Edit user: ${user.name}');
                                          // TODO: Navigasi ke halaman edit customer
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Fitur edit untuk ${user.name} belum diimplementasikan.')),
                                          );
                                        },
                                      ),
                                      // ### TOMBOL VIEW (Detail) ###
                                      IconButton(
                                        icon: Icon(Icons.visibility, color: Tcolor.primary),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailView(user: user)));
                                        },
                                      ),
                                      // ### TOMBOL DELETE ###
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(user);
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailView(user: user)));
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}