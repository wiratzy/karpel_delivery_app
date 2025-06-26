import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/common_widget/round_textfield.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Text("New Password",
                  style: TextStyle(
                      color: Tcolor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              Center(
                child: Text(
                  "Please enter your New Password",
                  style: TextStyle(
                    color: Tcolor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign
                      .center, // Menambahkan textAlign untuk memastikan teks terpusat
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "New Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 60,
              ),
              RoundButton(title: "Send", onPressed: () {}),
              const SizedBox(
                height: 4,
              ),

              // TextButton(
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => const LoginView()));
              //     },
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           "Already Have an Account? ",
              //           style: TextStyle(
              //               color: Tcolor.secondaryText,
              //               fontSize: 14,
              //               fontWeight: FontWeight.w500),
              //         ),
              //         Text(
              //           "Login",
              //           style: TextStyle(
              //               color: Tcolor.primary,
              //               fontSize: 14,
              //               fontWeight: FontWeight.w500),
              //         ),
              //       ],
              //     ))
            ],
          ),
        ),
      ),
    );
  }
}
