import 'dart:convert';
import 'package:http/http.dart' as http;

/// Replace with your actual Groq API key
const String groqApiKey = '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';

/// Groq API endpoint for chat completions
final Uri groqUrl = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

/// Function to send raw text and get cleaned JSON back
Future<Map<String, dynamic>?> cleanReportWithGroq(String rawText) async {
  try {
    final prompt = '''
  you will be given a non 
{
  "labHistory": {
    "TEST NAME": [
      {
        "value": ...,
        "normalRange": [..., ...],
        "status": "normal/high/low"
      }
    ],
    ...
  },
  "summary": {
    "TEST NAME": {
      "latestValue": ...,
      "trend": "...",
      "status": "..."
    }
  },
  "doctorConsultation": {
    "recommended": true/false,
    "reason": "...",
    "questions": ["...", "..."]
  }
}

Here is the raw lab report text:

$rawText
''';

    final body = {
      "model": "meta-llama/llama-4-scout-17b-16e-instruct", // Replace with the desired model
      "messages": [
        {
          "role": "user",
          "content": prompt,
        }
      ],
      "temperature": 0.7
    };

    final response = await http.post(
      groqUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $groqApiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];

      if (content != null && content is String) {
        final clean = _extractJsonFromText(content);
        return jsonDecode(clean);
      }
    }

    print('Groq response error: ${response.body}');
    return null;
  } catch (e) {
    print('Groq exception: $e');
    return null;
  }
}

/// Cleans the Groq response by stripping markdown fences and logs
String _extractJsonFromText(String input) {
  var trimmed = input.trim();
  if (trimmed.startsWith('```') && trimmed.endsWith('```')) {
    trimmed = trimmed.substring(3, trimmed.length - 3).trim();
  }
  return trimmed;
}
