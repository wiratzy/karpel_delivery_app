import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kons2/cofing.dart';
import 'package:provider/provider.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/common_widget/round_textfield.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/view/more/my_order_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final picker = ImagePicker();
  XFile? image;

  final txtName = TextEditingController();
  final txtEmail = TextEditingController();
  final txtMobile = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConfirmPassword = TextEditingController();

  String? selectedAddress;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      txtName.text = user.name;
      txtEmail.text = user.email;
      txtMobile.text = user.phone;
      selectedAddress = user.address;
      // latitude & longitude bisa disimpan saat login jika backend mengirim datanya
    }
  }

  @override
  void dispose() {
    txtName.dispose();
    txtEmail.dispose();
    txtMobile.dispose();
    txtPassword.dispose();
    txtConfirmPassword.dispose();
    super.dispose();
  }

  Future<void> pickLocationFromMap() async {
    final result = await Navigator.pushNamed(context, '/mapPicker');
    if (result is Map<String, dynamic>) {
      setState(() {
        selectedAddress = result['formatted_address'];
        latitude = result['latitude'];
        longitude = result['longitude'];
      });
    }
  }

  Future<void> handleUpdate() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);

  if (txtName.text.isEmpty ||
      txtEmail.text.isEmpty ||
      txtMobile.text.isEmpty ||
      selectedAddress == null ||
      latitude == null ||
      longitude == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text("Semua field harus diisi termasuk lokasi")),
    );
    return;
  }

  if (txtPassword.text.isNotEmpty &&
      txtPassword.text != txtConfirmPassword.text) {
    messenger.showSnackBar(
      const SnackBar(content: Text("Password tidak cocok")),
    );
    return;
  }

  try {
    await auth.updateUser(
      name: txtName.text,
      email: txtEmail.text,
      phone: txtMobile.text,
      address: selectedAddress!,
      latitude: latitude!,
      longitude: longitude!,
      password: txtPassword.text.isNotEmpty ? txtPassword.text : null,
      photo: image != null ? File(image!.path) : null,
    );

    if (mounted) {
      setState(() => image = null);
      messenger.showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
    }
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text("Gagal memperbarui profil: $e")),
    );
  }
}


  Future<void> handleLogout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 46),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProfileImage(user?.photo),
            _buildEditPhotoButton(),
            Text(
              "Hi there ${user?.name ?? 'User'}!",
              style: TextStyle(
                color: Tcolor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: handleLogout,
              child: Text(
                "Sign Out",
                style: TextStyle(
                  color: Tcolor.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildField("Name", txtName),
            _buildField("Email", txtEmail, keyboardType: TextInputType.emailAddress),
            _buildField("Mobile No", txtMobile, keyboardType: TextInputType.phone),
            _buildAddressField(),
            _buildField("Password", txtPassword, obscureText: true, hint: "New Password (optional)"),
            _buildField("Confirm Password", txtConfirmPassword, obscureText: true, hint: "Confirm Password"),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IgnorePointer(
                ignoring: auth.isLoading,
                child: Opacity(
                  opacity: auth.isLoading ? 0.5 : 1.0,
                  child: RoundButton(
                    title: auth.isLoading ? "Loading..." : "Save",
                    onPressed: handleUpdate,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Profile",
            style: TextStyle(
              color: Tcolor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrderView())),
            icon: Image.asset("assets/img/shopping_cart.png", width: 25, height: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? photoUrl) {
  final authProvider = Provider.of<AuthProvider>(context);
  // Pastikan baseUrl dapat diakses, misalnya dari AuthProvider.apiService.baseUrl
  final String backendBaseUrl = baseUrl; 

  String? fullImageUrl;
  if (photoUrl != null && photoUrl.isNotEmpty) {
    // Sesuaikan path '/storage/' jika di backend Anda berbeda
    fullImageUrl = '$backendBaseUrl/storage/photos/$photoUrl'; 
  }

  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      color: Tcolor.placeholder,
      borderRadius: BorderRadius.circular(50),
    ),
    child: image != null // Ini untuk gambar yang baru dipilih dari galeri
        ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.file(
              File(image!.path),
              fit: BoxFit.cover, // <-- Pastikan ini
            ),
          )
        : fullImageUrl != null && fullImageUrl.isNotEmpty 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  fullImageUrl,
                  fit: BoxFit.cover, // <-- Pastikan ini
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image from network: $error');
                    print('Image URL attempted: $fullImageUrl');
                    return Icon(Icons.error, size: 65, color: Colors.red);
                  },
                ),
              )
            : Icon(Icons.person, size: 65, color: Tcolor.secondaryText),
  );
}

  Widget _buildEditPhotoButton() {
    return TextButton.icon(
      onPressed: () async {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() => image = picked);
        }
      },
      icon: Icon(Icons.edit, color: Tcolor.primary, size: 12),
      label: Text("Edit Profile", style: TextStyle(color: Tcolor.primary, fontSize: 12)),
    );
  }

  Widget _buildField(String title, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: RoundTitleTextfield(
        title: title,
        hintText: hint ?? "Enter $title",
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildAddressField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: GestureDetector(
        onTap: pickLocationFromMap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Tcolor.textfield,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedAddress ?? "Pilih lokasi di Maps",
                  style: TextStyle(
                    color: selectedAddress == null ? Tcolor.placeholder : Tcolor.primaryText,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
