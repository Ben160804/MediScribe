import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String apiUrl = 'https://libretranslate.de/translate';

  Future<String> translate(String text, String targetLanguage, {String sourceLanguage = 'auto'}) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'q': text,
        'source': sourceLanguage,
        'target': targetLanguage,
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['translatedText'];
    } else {
      throw Exception('Failed to load translation');
    }
  }
}
