import 'package:aignite2025_oops/screens/language%20selection_screen.dart';
import 'package:aignite2025_oops/screens/onboarding_screeen.dart';
import 'package:aignite2025_oops/translation/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/component_controllers/image_controller.dart';
import 'controllers/component_controllers/language_controller.dart';
import 'controllers/component_controllers/pdf_controller.dart';
import 'screens/home_screen.dart';
 // <-- Import your translations file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register your controllers
  Get.put(PdfController());
  Get.put(ImageController());
  Get.put(LanguageController());

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
      // 🔤 Add translations
      translations: AppTranslations(), // <-- This class contains your i18n map
      locale: const Locale('en'),      // 🌐 Initial language (you can change dynamically)
      fallbackLocale: const Locale('en'), // 👇 In case translation key not found
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/language', page: () =>  LanguageScreen()),
        GetPage(name: '/onboarding', page: () =>  OnboardingScreen()),
        GetPage(name: '/home', page: () =>  HomeScreen()),
      ],
    );
  }
}
