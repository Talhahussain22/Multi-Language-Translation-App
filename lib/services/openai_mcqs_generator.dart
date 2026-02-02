import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/gemini_response_model.dart';

class OpenAIMCQService {
  Future<List<MCQQuestion>> generateMCQs({required String prompt_message}) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['APIKEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw 'OpenAI API key is missing. Please set OPENAI_API_KEY or APIKEY in .env';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      // No forced response_format because we expect a raw JSON array
      "messages": [
        {
          "role": "system",
          "content": "You are an MCQ generator. Always output ONLY a JSON array of questions that matches the expected schema, with no prose or markdown."
        },
        {"role": "user", "content": prompt_message}
      ]
    });

    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30), onTimeout: () {
          throw 'Request timed out. Please check your internet connection.';
        });

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final content = decoded['choices']?[0]?['message']?['content'];
          if (content is String && content.trim().isNotEmpty) {
            final cleaned = content
                .replaceAll("```json", "")
                .replaceAll("```", "")
                .trim();
            try {
              final dynamic parsed = jsonDecode(cleaned);
              if (parsed is List) {
                return parsed.map((e) => MCQQuestion.fromJson(e as Map<String, dynamic>)).toList();
              }
              if (parsed is Map && parsed['data'] is List) {
                final list = parsed['data'] as List;
                return list.map((e) => MCQQuestion.fromJson(e as Map<String, dynamic>)).toList();
              }
              throw 'Unexpected JSON shape for MCQs.';
            } catch (e) {
              throw e.toString();
            }
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
