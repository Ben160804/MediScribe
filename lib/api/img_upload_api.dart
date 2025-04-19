import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  final String uploadUrl = 'https://your-api-endpoint.com/upload'; // Replace with your actual API

  Future<http.Response?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      var fileStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var multipartFile = http.MultipartFile(
        'file', // Make sure this matches your API's field name
        fileStream,
        length,
        filename: basename(imageFile.path),
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("Image uploaded successfully: ${response.body}");
        return response;
      } else {
        print("Failed to upload image. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
