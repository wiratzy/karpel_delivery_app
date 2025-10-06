// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:karpel_food_delivery/models/admin_restaurant_model.dart';
// import 'package:karpel_food_delivery/providers/admin_restaurant_provider.dart';
// import 'package:provider/provider.dart';

// class CreateEditRestaurantView extends StatefulWidget {
//   final AdminRestaurant? restaurant;
//   const CreateEditRestaurantView({super.key, this.restaurant});

//   @override
//   State<CreateEditRestaurantView> createState() => _CreateEditRestaurantViewState();
// }

// class _CreateEditRestaurantViewState extends State<CreateEditRestaurantView> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _phoneController = TextEditingController();
//   XFile? _pickedImage;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.restaurant != null) {
//       _nameController.text = widget.restaurant!.name;
//       _addressController.text = widget.restaurant!.address ?? '';
//       _phoneController.text = widget.restaurant!.phone ?? '';
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _pickedImage = picked);
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     final provider = context.read<AdminRestaurantProvider>();

//     final body = {
//       'name': _nameController.text,
//       'address': _addressController.text,
//       'phone': _phoneController.text,
//     };

//     try {
//       if (widget.restaurant == null) {
//         await provider.addRestaurant(body);
//       } else {
//         await provider.editRestaurant(widget.restaurant!.id, body);
//       }
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Gagal menyimpan data: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.restaurant != null;
//     return Scaffold(
//       appBar: AppBar(title: Text(isEdit ? 'Edit Restoran' : 'Tambah Restoran')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 180,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                     image: _pickedImage != null
//                         ? DecorationImage(
//                             image: FileImage(File(_pickedImage!.path)),
//                             fit: BoxFit.cover,
//                           )
//                         : widget.restaurant?.photo != null
//                             ? DecorationImage(
//                                 image: NetworkImage(widget.restaurant!.photo!),
//                                 fit: BoxFit.cover,
//                               )
//                             : null,
//                   ),
//                   child: _pickedImage == null && widget.restaurant?.photo == null
//                       ? const Center(child: Icon(Icons.add_a_photo, size: 40))
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Nama Restoran'),
//                 validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: 'Alamat'),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(labelText: 'No. Telepon'),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Restoran'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }