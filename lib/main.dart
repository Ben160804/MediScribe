import 'package:aignite2025_oops/screens/language%20selection_screen.dart';
import 'package:aignite2025_oops/screens/onboarding_screeen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/component_controllers/user_controller.dart';
import 'firebase_options.dart';
import 'translation/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

// Controllers
import 'controllers/component_controllers/pdf_controller.dart';
import 'controllers/component_controllers/image_controller.dart';
import 'controllers/component_controllers/language_controller.dart';
import 'controllers/page_controllers/login_page_controller.dart';
import 'controllers/page_controllers/register_page_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize GetStorage before running the app
  await GetStorage.init();

  // Register global controllers
  Get.put(PdfController());
  Get.put(ImageController());
  Get.put(LanguageController());
  Get.put(LoginController());
  Get.put(RegisterController());
  Get.put(UserController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController langController = Get.find();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MediScribe',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7E57C2),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.robotoTextTheme(),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Color(0xFF7E57C2),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            backgroundColor: Color(0xFF7E57C2),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7E57C2),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Color(0xFF7E57C2),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            backgroundColor: Color(0xFF7E57C2),
          ),
        ),
        translations: AppTranslations(),
        locale:
            langController.selectedLanguage.isNotEmpty
                ? Locale(langController.selectedLanguage.value)
                : const Locale('en'),
        fallbackLocale: const Locale('en'),
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/language', page: () => LanguageScreen()),
          GetPage(name: '/onboarding', page: () => OnboardingScreen()),
          GetPage(name: '/home', page: () => HomeScreen()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/register', page: () => RegisterScreen()),
        ],
      );
    });
  }
}
