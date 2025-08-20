import 'dart:convert';
import 'package:ai_text_to_speech/const/app_url.dart';
import 'package:http/http.dart' as http;

class NetworkServices {
  Future<dynamic> streamTranslate(
    String text,
    String toLanguage,
    String fromLanguage,
  ) async {
    final postUrl = Uri.parse(APPURL.base_url);

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "data": [text, fromLanguage, toLanguage],
    });
    final eventId;
    try {
      final postResponse = await http
          .post(postUrl, headers: headers, body: body)
          .timeout(
            Duration(seconds: 20),
            onTimeout: () {
              throw 'Unable to Translate check your internet connection';
            },
          );
      if (postResponse.statusCode != 200) {
        throw 'A unknown error occurred check your Internet Connection';
      }

      eventId = jsonDecode(postResponse.body)['event_id'];
    } catch (e) {
      if(e.toString().contains('ClientException with SocketException'))
        {
          throw 'Unable to Translate check your internet connection.';
        }
      throw e.toString();
    }

    try {
      final streamUrl = Uri.parse("${APPURL.base_url}/$eventId");

      final client = http.Client();
      final streamedResponse = await client
          .send(http.Request("GET", streamUrl))
          .timeout(
            Duration(seconds: 20),
            onTimeout: () {
              throw 'Unable to Translate check your internet connection';
            },
          );

      final buffer = StringBuffer();
      String? finalOutput;

      await for (final chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        final lines = chunk.split('\n');

        for (var line in lines) {
          if (line.startsWith("data:")) {
            final jsonString = line.replaceFirst("data: ", "").trim();
            try {
              final List<dynamic> decoded = jsonDecode(jsonString);
              final String currentText = decoded[0];

              buffer.clear();
              buffer.write(currentText);
            } catch (e) {
              throw 'Error Occured During Translation';
            }
          } else if (line.startsWith("event: complete")) {
            finalOutput = buffer.toString();

            client.close();
            return finalOutput;
          }
        }
      }
    } catch (e) {

      throw e.toString();
    }
  }
}
