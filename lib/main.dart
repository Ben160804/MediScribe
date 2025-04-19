import 'package:aignite2025_oops/screens/language%20selection_screen.dart';
import 'package:aignite2025_oops/screens/onboarding_screeen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'controllers/component_controllers/pdf_controller.dart';
import 'screens/home_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(PdfController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediScribe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/language',
      getPages: [
        GetPage(name: '/language', page: () => const LanguageScreen()),
        GetPage(name: '/onboarding', page: () =>  OnboardingScreen()),
        GetPage(name: '/home', page: () =>  HomeScreen()),
      ],
    );
  }
}
