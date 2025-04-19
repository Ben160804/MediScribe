import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  PageController pageController = PageController();
  var currentPage = 0.obs;

  final GetStorage _storage = GetStorage();

  // Onboarding data, will be updated based on language preference
  List<Map<String, String>> onboardingData = [];

  @override
  void onInit() {
    super.onInit();
    // Load language preference from GetStorage
    String language = _storage.read('language') ?? 'en';
    loadOnboardingData(language);
  }

  // Function to load onboarding data based on the language
  void loadOnboardingData(String language) {
    if (language == 'bn') {
      onboardingData = [
        {
          "title": "আপনার মেডিকেল রিপোর্ট বুঝুন",
          "description": "MediScribe জটিল মেডিকেল টার্ম সহজ ভাষায় ব্যাখ্যা করে।",
          "image": "assets/1st.png"
        },
        {
          "title": "সহজেই আপলোড বা স্ক্যান করুন",
          "description": "একটি ছবি তুলুন বা রিপোর্ট আপলোড করুন – আমরা বাকিটা দেখবো।",
          "image": "assets/2nd.png"
        },
        {
          "title": "তাত্ক্ষণিক AI বিশ্লেষণ",
          "description": "হাইলাইট, অনুবাদিত রেজাল্ট এবং বুদ্ধিমান প্রশ্নাবলি পান।",
          "image": "assets/3rd.png"
        },
      ];
    } else {
      onboardingData = [
        {
          "title": "Understand Your Medical Report",
          "description": "MediScribe explains complex medical terms in simple language.",
          "image": "assets/1st.png"
        },
        {
          "title": "Easily Upload or Scan",
          "description": "Take a photo or upload a report – we’ll handle the rest.",
          "image": "assets/2nd.png"
        },
        {
          "title": "Instant AI Analysis",
          "description": "Get highlighted, translated results and intelligent questions.",
          "image": "assets/3rd.png"
        },
      ];
    }
  }

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offAllNamed('/login'); // 🟣 Navigate when at last page
    }
  }

  void skip() {
    Get.offAllNamed('/login'); // 🟣 Immediately go to Login
  }

  void disposeController() {
    pageController.dispose();
  }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }
}
