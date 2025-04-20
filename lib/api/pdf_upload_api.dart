import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../screens/labreport.dart';
import 'gemini.dart';

// Clean up the raw response safely
String cleanRawJson(String raw) {
  // Remove Markdown code block if present
  if (raw.trim().startsWith('```')) {
    raw = raw.replaceAll('```', '').trim();
  }

  // Remove escape sequences like \n, \r
  raw = raw.replaceAll(r'\n', '').replaceAll(r'\r', '');

  return raw.trim();
}

// Pretty print in safe chunks for the terminal
void printJsonInChunks(String jsonString, {int chunkSize = 800}) {
  for (int i = 0; i < jsonString.length; i += chunkSize) {
    int end = (i + chunkSize < jsonString.length) ? i + chunkSize : jsonString.length;
    print(jsonString.substring(i, end));
  }
}

// Upload PDF and process the response
Future<http.Response?> uploadPdf(File pdfFile) async {
  try {
    final uri = Uri.parse('https://backend-mediscribe.onrender.com/upload');

    var request = http.MultipartRequest('POST', uri);
    var stream = http.ByteStream(pdfFile.openRead());
    var length = await pdfFile.length();

    var multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: basename(pdfFile.path),
    );

    request.files.add(multipartFile);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final rawText = response.body;

      print("Cleaning and decoding raw JSON...");

      final cleaned = cleanRawJson(rawText);

      try {
        final decoded = jsonDecode(rawText);

        print("decoded: $decoded");
        final prettyJson = const JsonEncoder.withIndent('  ').convert(decoded);
        printJsonInChunks(prettyJson);

        final cleanedData = await cleanReportWithGroq(cleaned);
        Get.to(() => LabReportScreen(labHistory: decoded['labHistory']));
        if (decoded != null && decoded.containsKey("labHistory")) {
          Get.to(() => LabReportScreen(labHistory: decoded['labHistory']));
        } else {
          print("Failed to parse cleaned data from Groq.");
        }
      } catch (e) {
        print("❌ JSON Decode failed: $e");
        print("Raw text was:\n$cleaned");
      }
    } else {
      print("Failed to upload PDF. Status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error uploading PDF: $e");
    return null;
  }
}
