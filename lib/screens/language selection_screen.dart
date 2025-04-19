import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/component_controllers/language_controller.dart';

class LanguageScreen extends StatelessWidget {
  LanguageScreen({super.key});

  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Name at top-left
              Text(
                'app_name'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 20),

              // Heading
              Center(
                child: Text(
                  'choose_language'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Language Options
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLanguageButton('English', 'en', Icons.language),
                    const SizedBox(height: 30),
                    _buildLanguageButton('বাংলা', 'bn', Icons.translate),
                  ],
                ),
              ),

              // Continue Button
              Obx(() {
                return controller.selectedLanguage.isNotEmpty
                    ? Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.proceed,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('continue'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String text, String code, IconData icon) {
    return Obx(() {
      final bool isSelected = controller.selectedLanguage.value == code;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () => controller.selectLanguage(code),
        ),
      );
    });
  }
}
