import 'package:aignite2025_oops/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/page_controllers/register_page_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final registerController = Get.find<RegisterController>();

  // Translations for English and Bengali
  final Map<String, String> en = {
    'register': 'Register',
    'fullName': 'Full Name',
    'email': 'Email',
    'phone': 'Phone',
    'age': 'Age',
    'password': 'Password',
    'alreadyHaveAccount': 'Already have an account? Login Now',
    'registerButton': 'REGISTER',
  };

  final Map<String, String> bn = {
    'register': 'নিবন্ধন করুন',
    'fullName': 'পূর্ণ নাম',
    'email': 'ইমেইল',
    'phone': 'ফোন',
    'age': 'বয়স',
    'password': 'পাসওয়ার্ড',
    'alreadyHaveAccount': 'আগেই অ্যাকাউন্ট আছে? লগইন করুন',
    'registerButton': 'নিবন্ধন করুন',
  };

  // Function to get the translated text based on language preference
  String translate(String key) {
    String selectedLang = GetStorage().read('language') ?? 'en';  // Default to 'en'
    return selectedLang == 'bn' ? bn[key] ?? key : en[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with curved image
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: size.height * 0.45,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                'assets/register.jpg', // Use the uploaded image path
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 250),
              child: Column(
                children: [
                  // Registration Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          translate("register"),  // Use translated text here
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        TextField(
                          decoration: InputDecoration(
                            hintText: translate("fullName"),  // Use translated text here
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => registerController.name.value = val,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextField(
                          decoration: InputDecoration(
                            hintText: translate("email"),  // Use translated text here
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => registerController.email.value = val,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: translate("phone"),  // Use translated text here
                            prefixIcon: const Icon(Icons.phone),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => registerController.phone.value = val,
                        ),
                        const SizedBox(height: 16),

                        // Age
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: translate("age"),  // Use translated text here
                            prefixIcon: const Icon(Icons.cake),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => registerController.age.value = val,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: translate("password"),  // Use translated text here
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => registerController.password.value = val,
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: registerController.isLoading.value
                                ? null
                                : registerController.register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9575CD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: registerController.isLoading.value
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Text(
                              translate("registerButton"),  // Use translated text here
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )),

                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Already registered? Login Now
                  TextButton(
                    onPressed: () {
                      Get.to(LoginScreen());
                    },
                    child: Text(
                      translate("alreadyHaveAccount"),  // Use translated text here
                      style: const TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
