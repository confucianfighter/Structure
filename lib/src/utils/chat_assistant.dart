import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Structure/src/data_types/object_box_types/chat_message.dart';

class ChatAssistant {
  String getApiKey() {
    return dotenv.get('OPENAI_API_KEY');
  }

  Future<void> sendMessage(
    List<ChatMessage> messageHistory,
    String context, // Context as instructions
    Future<void> Function(String) onChunkReceived,
    Future<void> Function(String) onError,
  ) async {
    // Prepend the context as a system message
    final messages = [
      {
        "role": "system",
        "content": context,
      },
      ...messageHistory
          .map((msg) => {
                "role": msg.role,
                "content": msg.content,
              })
          ,
    ];

    final requestBody = jsonEncode({
      "model": "gpt-4o-2024-08-06",
      "messages": messages,
      "stream": true,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getApiKey()}',
    };

    final client = http.Client();
    int retryCount = 0;
    const maxRetries = 3;
    const initialBackoff = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final request = http.Request(
          'POST',
          Uri.parse('https://api.openai.com/v1/chat/completions'),
        )
          ..headers.addAll(headers)
          ..body = requestBody;

        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode == 200) {
          final stream = streamedResponse.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter());

          await for (var line in stream) {
            if (line.startsWith('data: ')) {
              line = line.substring(6); // Remove 'data: ' prefix
            }
            if (line.trim().isEmpty) continue; // Skip empty lines

            try {
              final jsonResponse = jsonDecode(line);
              if (jsonResponse.containsKey('choices')) {
                final choices = jsonResponse['choices'] as List;
                for (var choice in choices) {
                  if (choice.containsKey('delta') &&
                      choice['delta'].containsKey('content')) {
                    final content = choice['delta']['content'] as String;
                    await onChunkReceived(content);
                  }
                }
              }
            } catch (e) {
              print('Error decoding JSON line: $line');
            }
          }
          break;
        } else {
          await onError('Error: ${streamedResponse.reasonPhrase}');
          break;
        }
      } catch (e) {
        print(e);
        await onError('Error: $e');
        if (retryCount < maxRetries - 1) {
          await Future.delayed(initialBackoff * (1 << retryCount));
        }
        retryCount++;
      }
    }
    client.close();
  }
}
