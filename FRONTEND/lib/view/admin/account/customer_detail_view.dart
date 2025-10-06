import 'package:flutter/material.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/models/user_model.dart';

class CustomerDetailView extends StatelessWidget {
  final User user;
  const CustomerDetailView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${user.name}'),
        backgroundColor: Tcolor.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Tcolor.placeholder,
                backgroundImage: user.photo != null ? NetworkImage(user.photo!) : null,
                child: user.photo == null 
                  ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U', style: TextStyle(fontSize: 50, color: Tcolor.primary, fontWeight: FontWeight.bold))
                  : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(icon: Icons.person, label: 'Nama', value: user.name),
            _buildDetailRow(icon: Icons.email, label: 'Email', value: user.email),
            _buildDetailRow(icon: Icons.phone, label: 'Telepon', value: user.phone),
            _buildDetailRow(icon: Icons.location_on, label: 'Alamat', value: user.address),
            _buildDetailRow(icon: Icons.shield_outlined, label: 'Role', value: user.role),
            if(user.restaurantId != null)
              _buildDetailRow(icon: Icons.store, label: 'Restaurant ID', value: user.restaurantId.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Tcolor.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}