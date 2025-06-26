import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/common_widget/round_textfield.dart';
import 'package:kons2/providers/auth_provider.dart';
import 'package:kons2/view/login/reset_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  Future<void> handleLogin(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (txtEmail.text.isEmpty || txtPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan password tidak boleh kosong"),
        ),
      );
      return;
    }

    try {
      await auth.login(txtEmail.text, txtPassword.text, context);
      // Navigasi sudah ditangani di AuthProvider
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Tampilkan dialog konfirmasi sebelum kembali
        bool? shouldPop = await showDialog<bool>(
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
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
                ),
                const SizedBox(height: 25),
                RoundTextfield(
                  hintText: "Password",
                  controller: txtPassword,
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => IgnorePointer(
                    ignoring: auth.isLoading,
                    child: Opacity(
                      opacity: auth.isLoading ? 0.5 : 1.0,
                      child: RoundButton(
                        title: auth.isLoading ? "Loading..." : "Login",
                        onPressed: () => handleLogin(context),
                      ),
                    ),
                  ),
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
    );
  }
}