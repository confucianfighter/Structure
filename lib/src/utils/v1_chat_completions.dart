import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:Structure/src/data_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Structure/src/data_types/code_editor/language_option.dart';
import 'response_schemas/schemas.dart';

class V1ChatCompletions {
  String getApiKey() {
    return dotenv.get('OPENAI_API_KEY');
  }

  Future<T?> sendMessage<T>({
    required String userMessage,
    Future<String>? Function()? getContext,
    String? systemPrompt,
    required Future<void> Function(String) onChunkReceived,
    required StructuredResponse<T> responseSchema,
    String? subject,
    required Future<void> Function(String) onError,
  }) async {
    final context = getContext != null ? await getContext() : "";
    systemPrompt = systemPrompt ?? "";
    systemPrompt += context ?? "";

    final messages = [
      {"role": "system", "content": "$systemPrompt"},
      {"role": "user", "content": "$userMessage"}
    ];

    final requestBody = jsonEncode({
      "model": "gpt-4o-2024-08-06",
      "messages": messages,
      "response_format": responseSchema.responseFormat,
      "stream": true
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getApiKey()}',
    };

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
      final request = http.Request('POST', uri)
        ..headers.addAll(headers)
        ..body = requestBody;

      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        StringBuffer buffer = StringBuffer();
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
                  print('content: $content');
                  buffer.write(content);
                  await onChunkReceived(content);
                }
              }
            }
          } catch (e) {
            print('Error decoding JSON line: $line');
          }
        }

        return responseSchema.decode(buffer.toString(), onError);
      } else {
        final responseBody = await response.stream.bytesToString();
        await onChunkReceived('Error: ${response.statusCode} ${response.reasonPhrase} $responseBody');
        return null;
      }
    } catch (e) {
      print(e);
      await onChunkReceived('Error: $e');
      await onError('Error: $e');
      return null;
    }
  }
}
