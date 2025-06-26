import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/common_widget/round_textfield.dart';
import 'package:kons2/providers/auth_provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();

  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  Future<void> _handleRegister() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (txtName.text.isEmpty ||
        _selectedAddress == null ||
        _latitude == null ||
        _longitude == null ||
        txtPhone.text.isEmpty ||
        txtEmail.text.isEmpty ||
        txtPassword.text.isEmpty ||
        txtConfirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok")),
      );
      return;
    }

    try {
      await auth.register(
        name: txtName.text,
        address: _selectedAddress!,
        latitude: _latitude!,
        longitude: _longitude!,
        phone: txtPhone.text,
        email: txtEmail.text,
        password: txtPassword.text,
        autoLogin: true,
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register gagal: $e")),
      );
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.pushNamed(context, '/mapPicker');
    if (result is Map) {
      setState(() {
        _selectedAddress = result['formatted_address'];
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Tidak'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              Text(
                "Sign Up",
                style: TextStyle(
                  color: Tcolor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Add your details to Sign up",
                style: TextStyle(
                  color: Tcolor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Name",
                controller: txtName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: _pickLocation,
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
                          _selectedAddress ?? "Pilih Lokasi di Maps",
                          style: TextStyle(
                            color: _selectedAddress == null
                                ? Tcolor.placeholder
                                : Tcolor.primaryText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Phone",
                controller: txtPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => IgnorePointer(
                  ignoring: auth.isLoading,
                  child: Opacity(
                    opacity: auth.isLoading ? 0.5 : 1.0,
                    child: RoundButton(
                      title: auth.isLoading ? "Loading..." : "Sign Up",
                      onPressed: _handleRegister,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already Have an Account? ",
                      style: TextStyle(
                        color: Tcolor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: Tcolor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
