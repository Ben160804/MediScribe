import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/component_controllers/language_controller.dart';
import 'package:aignite2025_oops/controllers/component_controllers/image_controller.dart';
import 'package:aignite2025_oops/screens/home_content.dart';
import 'package:aignite2025_oops/screens/img_preview.dart';
import 'package:aignite2025_oops/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxInt _selectedIndex = 0.obs;

  final List<Widget> _screens = [
    const HomeContent(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final langController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() {
          final isBengali = langController.selectedLanguage.value == 'bn';
          final titles = [
            isBengali ? 'হোম স্ক্রীন' : 'Home Screen',
            isBengali ? 'প্রোফাইল' : 'Profile',
          ];
          return Text(titles[_selectedIndex.value]);
        }),
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
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: Obx(() => _screens[_selectedIndex.value]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9575CD),
        onPressed: () async {
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(source: ImageSource.camera);

          if (pickedFile != null) {
            final imageFile = File(pickedFile.path);
            Get.find<ImageController>().pickImage(imageFile);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getTranslatedText(
                    'Image captured successfully', langController)),
              ),
            );

            Get.to(() => ImagePreviewScreen());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getTranslatedText(
                    'No image captured', langController)),
              ),
            );
          }
        },
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFFF3E5F5),
        elevation: 8,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  langController: langController,
                ),
                const SizedBox(width: 48),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 1,
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
              size: 26,
              color: isSelected ? const Color(0xFF7E57C2) : Colors.black54,
            ),
            Text(
              translatedLabel,
              style: TextStyle(
                fontSize: 13,
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
