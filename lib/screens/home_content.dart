import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/component_controllers/pdf_controller.dart';
import '../controllers/component_controllers/language_controller.dart';
import 'pdf_preview.dart';
import 'result_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfController = Get.find<PdfController>();
    final langController = Get.find<LanguageController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFont = screenWidth > 600 ? 26.0 : 22.0;
    final subtitleFont = screenWidth > 600 ? 16.0 : 13.0;
    final tilePadding = screenWidth > 600 ? 24.0 : 16.0;

    final List<_Feature> features = [
      _Feature(
        id: 'select_report',
        title: 'Select report from Gallery',
        subtitle: 'Scan and get insights',
        icon: Icons.upload_file,
        color: const Color(0xFF7E57C2),
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (result != null && result.files.single.path != null) {
            File file = File(result.files.single.path!);
            pdfController.pickPdf(file);
            Get.to(() => const PdfPreviewScreen());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  langController.selectedLanguage.value == 'bn'
                      ? 'পিডিএফ সফলভাবে নির্বাচিত হয়েছে'
                      : 'PDF selected successfully',
                ),
                backgroundColor: const Color(0xFF7E57C2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  langController.selectedLanguage.value == 'bn'
                      ? 'কোনো পিডিএফ নির্বাচন করা হয়নি'
                      : 'No PDF selected',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
      _Feature(
        id: 'previous_reports',
        title: 'Previous Reports',
        subtitle: 'View your test history',
        icon: Icons.history,
        color: const Color(0xFF6A1B9A),
        onTap: () {
          if (FirebaseAuth.instance.currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  langController.selectedLanguage.value == 'bn'
                      ? 'দয়া করে প্রথমে লগইন করুন'
                      : 'Please login first',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          Get.to(() => const ResultScreen());
        },
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tilePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(titleFont, langController),
              const SizedBox(height: 8),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _buildLargeFeatureTile(
                    context,
                    f,
                    subtitleFont,
                    tilePadding,
                    langController,
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double fontSize, LanguageController langController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            langController.selectedLanguage.value == 'bn'
                ? 'মেডিস্ক্রাইব'
                : 'MediScribe',
            style: GoogleFonts.roboto(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF9575CD)),
                  onPressed: () {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;
                    final Offset offset = button.localToGlobal(
                      Offset.zero,
                      ancestor: overlay,
                    );
                    final Size size = button.size;

                    showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + size.height,
                        overlay.size.width - offset.dx - size.width,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.settings,
                                color: Color(0xFF7E57C2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                langController.selectedLanguage.value == 'bn'
                                    ? 'সেটিংস'
                                    : 'Settings',
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Color(0xFF7E57C2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                langController.selectedLanguage.value == 'bn'
                                    ? 'প্রোফাইল'
                                    : 'Profile',
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Color(0xFF7E57C2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                langController.selectedLanguage.value == 'bn'
                                    ? 'লগআউট'
                                    : 'Log Out',
                              ),
                            ],
                          ),
                        ),
                      ],
                      color: const Color(0xFFF3E5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeFeatureTile(
    BuildContext context,
    _Feature feature,
    double subtitleFont,
    double tilePadding,
    LanguageController langController,
  ) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: feature.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: feature.color.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: feature.color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(tilePadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: feature.color,
              child: Icon(feature.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTranslatedText(feature.id, feature.title),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: subtitleFont + 4,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getTranslatedSubtitle(feature.id, feature.subtitle),
                    style: GoogleFonts.roboto(
                      fontSize: subtitleFont,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTranslatedText(String id, String defaultText) {
    final lang = Get.find<LanguageController>().selectedLanguage.value;
    if (lang == 'bn') {
      switch (id) {
        case 'select_report':
          return 'গ্যালারি থেকে রিপোর্ট নির্বাচন করুন';
        case 'previous_reports':
          return 'পূর্ববর্তী রিপোর্ট';
      }
    }
    return defaultText;
  }

  String _getTranslatedSubtitle(String id, String defaultText) {
    final lang = Get.find<LanguageController>().selectedLanguage.value;
    if (lang == 'bn') {
      switch (id) {
        case 'select_report':
          return 'স্ক্যান করুন এবং তথ্য পান';
        case 'previous_reports':
          return 'আপনার পূর্বের রিপোর্ট অ্যাক্সেস করুন';
      }
    }
    return defaultText;
  }
}

class _Feature {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _Feature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
