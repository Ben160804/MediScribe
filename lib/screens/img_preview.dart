import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../api/img_upload_api.dart';
import '/controllers/component_controllers/image_controller.dart';


class ImagePreviewScreen extends StatelessWidget {
  ImagePreviewScreen({super.key});

  final imageController = Get.find<ImageController>();
  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: Obx(() {
        final imageFile = imageController.selectedImage.value;
        if (imageFile == null) {
          return const Center(child: Text('No image selected'));
        }

        return Column(
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
                    color: const Color(0xFF9575CD).withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // Analyze Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    print("Analyzing image...");
                    final file = imageController.selectedImage.value;
                    if (file != null) {
                      final response = await apiService.uploadImage(file);
                      if (response != null) {
                        Get.snackbar("Success", "Image processed successfully!",
                            snackPosition: SnackPosition.BOTTOM);
                        print("Response: ${response.body}");
                      } else {
                        Get.snackbar("Error", "Failed to process image.",
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    }
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text(
                    "Analyze Image",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9575CD),
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
        );
      }),
    );
  }
}
