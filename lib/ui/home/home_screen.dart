import 'package:draftpics/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:reutilizacao/ui/components/AppButton.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text("Im home ")),
        ReusableButton(onPressed: () => Get.toNamed(AppRoutes.addScreen)),
      ],
    );
  }
}
