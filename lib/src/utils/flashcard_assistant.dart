import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:Structure/src/data_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Structure/src/data_types/code_editor/language_option.dart';

class FlashcardAssistant {
  String getApiKey() {
    return dotenv.get('OPENAI_API_KEY');
  }

  Future<List<FlashCard>> generateFlashcards(
      String userMessage,
      List<FlashCard> existingFlashcards,
      Future<void> Function(String) onChunkReceived,
      {String? subject}) async {
    final existingQuestions =
        existingFlashcards.map((fc) => fc.question).toList();

    final messages = [
      {
        "role": "system",
        "content": "You are a helpful assistant that generates flashcards."
      },
      {
        "role": "user",
        "content":
            "Create a list of flashcards based on the following message: $userMessage. Each flashcard should have a question, an answer, and an answer code language (that way we can do syntax highlighting for them when they answer the question). The question will be displayed using html. Use <h2> for the question and <x> some code </x> when you want to include code in the question. The following languages are available for user response syntax highlighting: ${languageMap.keys.join(', ')}. Unless the user has said otherwise, return at most 7 flashcards. Avoid duplicating the following questions: ${existingQuestions.join(', ')}. And while the question is to be in html, the answer should be in either plain text or the code language, no markup. If there needs to be code and explanation, use code comments for explanation."
      }
    ];

    final responseFormat = {
      "type": "json_schema",
      "json_schema": {
        "name": "FlashcardResponse",
        "strict": true,
        "schema": {
          "type": "object",
          "properties": {
            "flashcards": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "question": {"type": "string"},
                  "answer": {"type": "string"},
                  "language": {
                    "type": "string",
                    "enum": languageMap.keys.toList()
                  }
                },
                "required": ["question", "answer", "language"],
                "additionalProperties": false,
              },
            },
          },
          "required": ["flashcards"],
          "additionalProperties": false,
        }
      }
    };

    final requestBody = jsonEncode({
      "model": "gpt-4o-2024-08-06",
      "messages": messages,
      "response_format": responseFormat,
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

        final jsonResponse = jsonDecode(buffer.toString());
        final flashcards = jsonResponse['flashcards'] as List;
        return flashcards
            .map((flashcard) => FlashCard(
                  id: 0,
                  question: flashcard['question'],
                  answer: flashcard['answer'],
                  answerInputLanguage: flashcard['language'],
                ))
            .toList();
      } else {
        await onChunkReceived('Error: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print(e);
      await onChunkReceived('Error: $e');
      return [];
    }
  }
}
