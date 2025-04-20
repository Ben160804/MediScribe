import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/pdf_upload_api.dart';
import '../controllers/component_controllers/pdf_controller.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({super.key});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool isLoading = true;
  int totalPages = 0;

  @override
  Widget build(BuildContext context) {
    final pdfController = Get.find<PdfController>();
    final pdfFile = pdfController.selectedPdf.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        centerTitle: true,
        title: Text(
          "PDF Report Preview",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: pdfFile != null
          ? Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade100,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF7E57C2).withOpacity(0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    PDFView(
                      filePath: pdfFile.path,
                      onRender: (pages) {
                        setState(() {
                          totalPages = pages ?? 0;
                          isLoading = false;
                        });
                      },
                      onError: (error) {
                        print("PDFView error: $error");
                      },
                    ),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (pdfFile != null) {
                    Get.snackbar("Uploading", "Analyzing PDF...",
                        snackPosition: SnackPosition.BOTTOM);

                    final response = await uploadPdf(pdfFile);

                    if (response != null) {
                      Get.snackbar("Success", "PDF uploaded successfully",
                          snackPosition: SnackPosition.BOTTOM);
                      print(response.body);
                    } else {
                      Get.snackbar("Error", "Failed to upload PDF",
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  }
                },
                icon: const Icon(Icons.analytics),
                label: Text(
                  "Analyze Report",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(child: Text("No PDF file selected.")),
    );
  }
}
