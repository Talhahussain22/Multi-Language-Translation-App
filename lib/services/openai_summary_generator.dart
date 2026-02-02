import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAISummary {
  Future<String> getSummary({
    required String topic,
    required List<String> words,
    required String targetLanguage,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['APIKEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw 'OpenAI API key is missing. Please set OPENAI_API_KEY or APIKEY in .env';
    }

    final prompt = '''You are a helpful assistant.

Generate a single coherent paragraph on the topic: "$topic".

Mandatory:
- Use ALL of the following vocabulary words naturally in the text: ${words.map((w) => '"$w"').join(', ')}
- Write in the target language: $targetLanguage
- Medium difficulty, friendly and easy to understand.
- Only output the paragraph text, no definitions, no lists, no explanations, no markdown.
''';

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": "You write concise paragraphs that strictly follow instructions."
        },
        {"role": "user", "content": prompt}
      ]
    });

    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 25), onTimeout: () {
          throw 'Request timed out. Please check your internet connection.';
        });

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final content = decoded['choices']?[0]?['message']?['content'];
          if (content is String && content.trim().isNotEmpty) {
            return content.trim();
          } else {
            throw 'No content returned from OpenAI.';
          }
        } else if (response.statusCode == 429 || response.statusCode >= 500) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          throw 'OpenAI API error: ${response.statusCode} ${response.body}';
        }
      } catch (e) {
        if (attempt >= maxRetries) {
          if (e.toString().contains('ClientException') &&
              e.toString().contains('SocketException')) {
            throw 'Please check your internet connection.';
          }
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    throw 'Try again in a few seconds.';
  }
}
