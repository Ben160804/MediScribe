import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _baseUrl =
      'https://translater-en-bn.onrender.com/translate';

  static Future<String> translateToBengali(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translatedText'] ?? text;
      }
      return text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }
}
