import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  void _proceed() {
    if (_selectedLanguage != null) {
      Get.toNamed('/onboarding');
    }
  }

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
              const Text(
                'MediScribe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 40),

              // "Choose Your Language" heading




              // Centered Language Options
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
              if (_selectedLanguage != null)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _proceed,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String text, String code, IconData icon) {
    final bool isSelected = _selectedLanguage == code;

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.black),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => _selectLanguage(code),
      ),
    );
  }
}
