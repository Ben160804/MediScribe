import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/component_controllers/language_controller.dart';
import '/controllers/component_controllers/image_controller.dart';
import 'home_content.dart';
import 'img_preview.dart';
import 'profile_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxInt _selectedIndex = 0.obs;

  final List<Widget> _screens = [
    const HomeContent(),
    const ResultScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final langController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(
          () => Text(
            langController.selectedLanguage.value == 'bn'
                ? 'মেডিস্ক্রাইব'
                : 'MediScribe',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Obx(() {
            final isBengali = langController.selectedLanguage.value == 'bn';
            return IconButton(
              icon: const Icon(Icons.language),
              tooltip: isBengali ? 'Switch to English' : 'বাংলায় যান',
              onPressed: () {
                final newLang = isBengali ? 'en' : 'bn';
                langController.selectLanguage(newLang);
              },
            );
          }),
        ],
        backgroundColor: const Color(0xFF7E57C2),
        foregroundColor: Colors.white,
      ),
      body: Obx(() => _screens[_selectedIndex.value]),
      floatingActionButton:
          _selectedIndex.value == 0
              ? FloatingActionButton(
                backgroundColor: const Color(0xFF7E57C2),
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );

                  if (pickedFile != null) {
                    final imageFile = File(pickedFile.path);
                    Get.find<ImageController>().pickImage(imageFile);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _getTranslatedText(
                            'Image captured successfully',
                            langController,
                          ),
                        ),
                        backgroundColor: const Color(0xFF7E57C2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );

                    Get.to(() => ImagePreviewScreen());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _getTranslatedText(
                            'No image captured',
                            langController,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFFF3E5F5),
        elevation: 4,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  langController: langController,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart,
                  label: 'Results',
                  index: 1,
                  langController: langController,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 2,
                  langController: langController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required LanguageController langController,
  }) {
    return Obx(() {
      final isSelected = _selectedIndex.value == index;
      final translatedLabel = _getTranslatedText(label, langController);
      return GestureDetector(
        onTap: () => _selectedIndex.value = index,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? const Color(0xFF7E57C2) : Colors.black54,
            ),
            const SizedBox(height: 4),
            Text(
              translatedLabel,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected ? const Color(0xFF7E57C2) : Colors.black54,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getTranslatedText(String text, LanguageController langController) {
    final lang = langController.selectedLanguage.value;

    if (lang == 'bn') {
      switch (text) {
        case 'Home':
          return 'বাড়ি';
        case 'Results':
          return 'ফলাফল';
        case 'Profile':
          return 'প্রোফাইল';
        case 'Image captured successfully':
          return 'ছবি সফলভাবে ক্যাপচার করা হয়েছে';
        case 'No image captured':
          return 'কোনো ছবি ক্যাপচার করা হয়নি';
      }
    }
    return text;
  }
}
