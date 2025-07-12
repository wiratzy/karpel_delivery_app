import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/common/color_extension.dart';
import 'package:karpel_food_delivery/common_widget/round_button.dart';
import 'package:karpel_food_delivery/common_widget/round_textfield.dart';
import 'package:karpel_food_delivery/providers/auth_provider.dart';
import 'package:karpel_food_delivery/view/login/reset_password_view.dart';
import 'dart:io';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

 // Di dalam LoginView -> _LoginViewState

Future<void> _handleLogin() async {
  if (!(_formKey.currentState?.validate() ?? false)) {
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  try {
    await authProvider.login(txtEmail.text, txtPassword.text);

    if (!mounted) return;

    // --- LANGKAH DEBUGGING: TAMBAHKAN PRINT DI SINI ---
    final user = authProvider.user;

    // Cetak seluruh objek user untuk melihat semua datanya
    print('DEBUG: Login Berhasil. Data User: ${user?.toJson()}'); 
    
    // Cetak role secara spesifik. Tanda kurung siku membantu melihat spasi kosong.
    print('DEBUG: Mengecek Role Pengguna: [${user?.role}]'); 

    // --- AKHIR LANGKAH DEBUGGING ---

   if (user?.role == 'customer') {
  Navigator.pushReplacementNamed(context, '/main'); // Atau route khusus customer kamu
}
 else {
      switch (user?.role) {
        case 'admin':
          print("DEBUG: Role cocok 'admin', mencoba navigasi ke /admin");
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 'restaurant_owner':
          print("DEBUG: Role cocok 'restaurant_owner', mencoba navigasi ke /restaurantOwner");
          Navigator.pushReplacementNamed(context, '/restaurantOwner');
          break;
        case 'driver':
          print("DEBUG: Role cocok 'driver', mencoba navigasi ke /driver");
          Navigator.pushReplacementNamed(context, '/driver');
          break;
        default:
          // Ini akan dieksekusi jika role-nya null atau tidak cocok sama sekali
          print("DEBUG: Role tidak cocok, navigasi ke /main sebagai default");
          Navigator.pushReplacementNamed(context, '/main');
      }
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login Gagal: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: const Text('Ya'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 64),
                  Text(
                    "Login",
                    style: TextStyle(
                      color: Tcolor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Add your details to login",
                    style: TextStyle(
                      color: Tcolor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),
                  RoundTextfield(
                    hintText: "Email",
                    controller: txtEmail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Masukkan format email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  RoundTextfield(
                    hintText: "Password",
                    controller: txtPassword,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return RoundButton(
                        title: auth.isLoading ? "Loading..." : "Login",
                        // PERBAIKAN DI SINI
                        onPressed: auth.isLoading ? null : () {
                          _handleLogin();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordView(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password ?",
                      style: TextStyle(
                        color: Tcolor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "or Login With",
                    style: TextStyle(
                      color: Tcolor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don't Have Account? ",
                          style: TextStyle(
                            color: Tcolor.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Sign Up",
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
        ),
      ),
    );
  }
}