import 'package:draftpics/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reutilizacao/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Draftpics App ',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.black26,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(
            context,
          ).textTheme, // Inherit existing text theme and override font
        ).apply(
          bodyColor: Colors.black, // Default body text color
          displayColor: Colors.black, // Default display text color
        ),
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
