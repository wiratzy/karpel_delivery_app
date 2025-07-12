import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/user_model.dart';
import 'package:karpel_food_delivery/services/api_services.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
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
  String? _token;

  @override
  void initState() {
    super.initState();
    _token = Provider.of<AuthProvider>(context, listen: false).token;
    if (_token != null) {
      _fetchUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token autentikasi tidak tersedia')),
      );
    }
  }

  Future<void> _fetchUsers() async {
    if (_token == null) return;
    try {
      final users = await _apiService.getAllUsers(_token!);
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  Future<void> _filterUsers(String query) async {
    if (_token == null) return;
    try {
      final users = await _apiService.searchUsers(_token!, query);
      setState(() {
        _filteredUsers = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(10),
              color: Tcolor.primary,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'USER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'SEARCH...',
                  filled: true,
                  fillColor: Tcolor.placeholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => _filterUsers(value),
              ),
            ),
            // List of Users
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return Card(
                    color: Tcolor.placeholder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.green),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('View ${user.email}')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.yellow),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Edit ${user.email}')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Delete ${user.email}')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}