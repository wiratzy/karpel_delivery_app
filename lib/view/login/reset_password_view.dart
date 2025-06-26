import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_button.dart';
import 'package:kons2/common_widget/round_textfield.dart';
import 'package:kons2/view/login/new_password_view.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  TextEditingController txtEmail = TextEditingController();
 
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
              Text("Reset Password",
                  style: TextStyle(
                      color: Tcolor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              Center(
                child: Text(
                  "Please enter your email to receive a link to create a new password via email",
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
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundButton(title: "Send", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPasswordView()));
              }),
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
