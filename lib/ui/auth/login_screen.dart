import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/auth/auth_controller.dart';
import 'package:reutilizacao/ui/components/AppButton.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ReusableTextField(
            labelText: "email",
            controller: controller.emailController,
          ),
        ),

        ReusableButton(
          onPressed: () {},
          isLoading: false,
          text: "Login",

          width: 200,
        ),
      ],
    );
  }
}
