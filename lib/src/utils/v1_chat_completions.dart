import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:Structure/src/data_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Structure/src/data_types/code_editor/language_option.dart';
import 'response_schemas/schemas.dart';

enum ChatCompletionAPI { OpenAI, DeepSeek }

class V1ChatCompletions {
  String getApiKey(ChatCompletionAPI api) {
    if (api == ChatCompletionAPI.OpenAI) {
      return dotenv.get('OPENAI_API_KEY');
    } else if (api == ChatCompletionAPI.DeepSeek) {
      return dotenv.get('DEEPSEEK_API_KEY');
    }
    return "";
  }

  Future<T?> sendMessage<T>({
    required String userMessage,
    Future<String>? Function()? getContext,
    String? systemPrompt,
    required Future<void> Function(String) onChunkReceived,
    required StructuredResponse<T> responseSchema,
    String? subject,
    required Future<void> Function(String) onError,
    ChatCompletionAPI api = ChatCompletionAPI.DeepSeek,
    Future<void> Function(String)? onThoughtChunkReceived,
    int maxTokens = 4096,
  }) async {
    final context = getContext != null ? await getContext() : "";
    systemPrompt = systemPrompt ?? "";
    if (api == ChatCompletionAPI.DeepSeek) {
      systemPrompt = '''Please reply in json format.$systemPrompt\n$context\n
      JSON SCHEMA TO FOLLOW: ${responseSchema.toJsonString()};
      NOTE: Output itself should not be a schema, but json object that follows the schema.''';
    }

    final messages = [
      {"role": "system", "content": "$systemPrompt"},
      {"role": "user", "content": "$userMessage"}
    ];

    final requestBody = api == ChatCompletionAPI.OpenAI
        ? jsonEncode({
            "model": "gpt-4o-2024-08-06",
            "messages": messages,
            "response_format": responseSchema.responseFormat,
            "stream": true
          })
        : jsonEncode({
            "model": "deepseek-reasoner",
            "messages": messages,
            "stream": true
          });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getApiKey(api)}',
    };
    late Uri uri;
    if (api == ChatCompletionAPI.OpenAI) {
      uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    } else if (api == ChatCompletionAPI.DeepSeek) {
      uri = Uri.parse('https://api.deepseek.com/chat/completions');
    }

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
        // get first line, if it starts with ```json, remove just the ```json from it

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
                if (choice.containsKey('delta')) {
                  if (choice['delta'].containsKey('content')) {
                    final content = choice['delta']['content'] as String;
                    print('content: $content');
                    buffer.write(content);
                    await onChunkReceived(content);
                  } else if (choice['delta'].containsKey('reasoning_content')) {
                    final content =
                        choice['delta']['reasoning_content'] as String;
                    print('content: $content');
                    await onChunkReceived(content);
                  }
                }
              }
            }
          } catch (e) {
            print('Error decoding JSON line: $line');
          }
        }

        String jsonString = buffer.toString();
        if (api == ChatCompletionAPI.DeepSeek) {
          if (jsonString.startsWith('```json')) {
            jsonString = jsonString.substring(7); // Remove '```json' prefix
          }
          if (jsonString.endsWith('```')) {
            jsonString = jsonString.substring(
                0, jsonString.length - 3); // Remove '```' suffix
          }
        }

        final result = responseSchema.decode(jsonString, onError);
        return result;
      } else {
        final responseBody = await response.stream.bytesToString();
        await onChunkReceived(
            'Error: ${response.statusCode} ${response.reasonPhrase} $responseBody');
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
