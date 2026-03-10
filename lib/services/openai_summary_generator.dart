import 'dart:convert';

import 'package:ai_text_to_speech/services/app_config.dart';
import 'package:http/http.dart' as http;

class OpenAISummary {
  Future<String> getSummary({
    required String topic,
    required List<String> words,
    required String targetLanguage,
  }) async {
    const apiKey = AppConfig.openAiApiKey;
    if (apiKey.isEmpty) {
      throw 'OpenAI API key is missing. Build with --dart-define=OPENAI_API_KEY=your-key';
    }

    final prompt = '''You are a friendly storyteller who makes learning fun!

Create a SHORT, SIMPLE, and ENGAGING paragraph about: "$topic"

📝 RULES:
- Use ALL these words naturally: ${words.map((w) => '"$w"').join(', ')}
- Write in $targetLanguage
- Keep it VERY SIMPLE - like talking to a friend
- Maximum 5-6 sentences
- Make it interesting and easy to read
- Use everyday language, no complex words
- Tell it like a story or conversation

❌ DO NOT:
- Use difficult vocabulary
- Make long sentences
- Add definitions or explanations
- Use markdown or formatting

✅ JUST OUTPUT: A short, friendly paragraph that naturally uses all the words.
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
