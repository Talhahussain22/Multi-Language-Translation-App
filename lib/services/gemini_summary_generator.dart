import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiSummary
{
  Future<String> getSummary({
    required String topic,
    required List<String> words,
    required String targetLanguage
})async{
  final prompt='''You are a helpful assistant.

Generate a summary or paragraph on the topic: "$topic", using required length.

Mandatory:
- Use all of the following vocabulary words naturally in the text: [$words]
- Write in the target language: $targetLanguage
- Make sure the language is user-friendly and easy to understand (medium difficulty)
- The summary should help the user understand how these words are used in real life.
- Do NOT include any definitions or explanations — just write a coherent, simple paragraph using the words naturally.
- Do not repeat the vocabulary list. Only provide the summary text as output.
- Only return text as output without formation, excalmation or something just pure json with text
 ''';

  final String model = 'gemini-2.0-flash';
  final apiKey = dotenv.env['APIKEY'];
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
  );

  final headers = {
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "contents": [
      {
        "parts": [
          {"text": prompt}
        ]
      }
    ]
  });

  const int maxRetries = 3;
  int attempt = 0;

  while (attempt < maxRetries) {
    attempt++;

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw 'Request timed out. Please check your internet connection.';
      });

      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);
        final contentText = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];


        if (contentText != null && contentText.trim().isNotEmpty) {
          final cleaned = contentText
              .replaceAll("```json", "")
              .replaceAll("```", "")
              .trim();

          return cleaned;
        } else {
          throw "No text returned. Please try again.";
        }
      } else if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        throw "Gemini API error: ${response.statusCode}";
      }
    } catch (e) {

      if (attempt >= maxRetries) {
        if(e.toString().contains('ClientException with SocketException'));
        {
          throw "Check your internet Connection and Retry";
        }
        throw "Failed after $maxRetries attempts: $e";
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  throw "Try After few seconds.";
  }


}
