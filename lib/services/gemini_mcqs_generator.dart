import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/gemini_response_model.dart';
class GeminiMCQService {
  Future<List<MCQQuestion>> generateMCQs({

    required String prompt_message,
  }) async {
    final String model = 'gemini-2.0-flash';
    final apiKey = dotenv.env['APIKEY'];
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final prompt =prompt_message;



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
            .timeout(Duration(seconds: 15), onTimeout: () {
          throw 'Request timed out. Please check your internet connection.';
        });


        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final contentText = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];

          if (contentText != null) {
            try {
              String cleaned = contentText
                  .replaceAll("```json", "")
                  .replaceAll("```", "")
                  .trim();

              final List<dynamic> jsonList = jsonDecode(cleaned);
              return jsonList.map((e) => MCQQuestion.fromJson(e)).toList();
            } catch (e) {
              throw "$e";
            }
          } else {
            throw "Not able to generate quiz. retry in few seconds";
          }
        } else if (response.statusCode == 503) {
          // Retry after a short delay
          await Future.delayed(Duration(seconds: 2));
        } else {
          print("Gemini API error: ${response.statusCode}");
        }
      } catch (e) {
        if (attempt >= maxRetries) {
          if(e.toString().contains('ClientException with SocketException'))
            {
              throw 'Please check your internet connection.';
            }
          throw "Failed after $maxRetries attempts: $e";
        } else {
          await Future.delayed(Duration(seconds: 2)); // backoff delay
        }
      }
    }

    throw "Try after few secodns.";
  }
}