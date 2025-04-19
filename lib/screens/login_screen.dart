import 'package:aignite2025_oops/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/page_controllers/login_page_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with curved bottom
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: size.height * 0.45,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                'assets/login.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 250), // push down under image
              child: Column(
                children: [
                  // Login card
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
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Username",
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => loginController.email.value = val,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => loginController.password.value = val,
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loginController.isLoading.value
                                ? null
                                : loginController.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9575CD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: loginController.isLoading.value
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "LOGIN",
                              style: TextStyle(
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

                  // Signup link
                  TextButton(
                    onPressed: () {
                      Get.to(RegisterScreen());
                    },
                    child: const Text(
                      "Not yet registered? SignUp Now",
                      style: TextStyle(
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

// Custom clipper to curve the bottom of the image
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
