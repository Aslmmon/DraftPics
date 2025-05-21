import 'package:draftpics/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reutilizacao/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Draftpics App ',
      theme: ThemeData(
        primaryColor: Colors.black26,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          scrolledUnderElevation: 0.0,
        ),
        colorScheme: ThemeData().colorScheme.copyWith(primary: Colors.black26),
      ),
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}
