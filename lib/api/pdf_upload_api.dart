import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

const String uploadUrl = 'https://your-api-url.com'; // replace with your base API URL
void printLongString(String text) {
  const int chunkSize = 800;
  for (int i = 0; i < text.length; i += chunkSize) {
    print(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
  }
}
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
      printLongString(response.body);
      return response;
    } else {
      print("Failed to upload PDF. Status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error uploading PDF: $e");
    return null;
  }

}
