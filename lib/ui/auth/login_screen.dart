import 'package:draftpics/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/auth/auth_controller.dart';
import 'package:reutilizacao/ui/components/AppButton.dart';
import 'package:reutilizacao/ui/components/AppTextField.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TeamUp',
          style: TextStyle(
            color: Colors.black, // Assuming a dark text color for "TeamUp"
            fontWeight: FontWeight.bold, // It looks bold
          ),
        ),
        centerTitle: true, // Center the title
        backgroundColor: Colors.white, // White background for the AppBar
        elevation: 0, // No shadow under the AppBar
      ),
      backgroundColor: Colors.white, // Overall white background for the screen
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 40),
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 32, // Large font size
                fontWeight: FontWeight.bold, // Bold
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // Spacing between headline and subtitle
            // "Manage your team and players with ease" subtitle
            const Text(
              'Manage your team and players with ease',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Grey color for subtitle
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40), // Spacing before input fields
            // Email TextField
            ReusableTextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              labelText: 'email',
            ),
            const SizedBox(height: 16), // Spacing between input fields
            ReusableTextField(
              controller: controller.passwordController,
              obscureText: true,
              labelText: 'password',
            ),
            const SizedBox(height: 32), // Spacing before the button
            ReusableButton(
              onPressed: () {
                // controller.login();
                Get.toNamed(AppRoutes.home);
              },
              text: "Login",
              isLoading: controller.isLoading.value,
              backgroundColor: Colors.blue,
              buttonTextColor: Colors.white,
            ),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red, // Grey color for subtitle
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
