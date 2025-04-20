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
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        color: const Color(0xFF7E57C2),
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
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              const SizedBox(height: 16),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
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
              color: const Color(0xFF7E57C2),
            ),
          ),
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF7E57C2)),
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
                                style: GoogleFonts.roboto(),
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
                                style: GoogleFonts.roboto(),
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
                                style: GoogleFonts.roboto(),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: feature.color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: feature.color.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, size: 32, color: feature.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feature.title,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: subtitleFont,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: feature.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _Feature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
