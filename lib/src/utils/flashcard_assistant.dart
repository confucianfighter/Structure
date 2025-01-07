import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../data_types/code_editor/language_option.dart';
import '../data_types/object_box_types/flash_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String getApiKey() {
  return dotenv.env['OPENAI_API_KEY']!;
}

class FlashcardAssistant {
  FlashcardAssistant() {
    OpenAI.apiKey = getApiKey();
  }

  Future<void> generateFlashcards(
      String userMessage,
      List<FlashCard> existingFlashcards,
      Function(String) onChunkReceived,
      {String? subject}) async {
    final existingQuestions =
        existingFlashcards.map((fc) => fc.question).toList();

    final messages = [
      OpenAIChatCompletionChoiceMessageModel(
        content: 'You are a helpful assistant that generates flashcards.',
        role: OpenAIChatMessageRole.system,
      ),
      OpenAIChatCompletionChoiceMessageModel(
        content:
            'Create a list of flashcards based on the following message: $userMessage. Each flashcard should have a question, an answer, and an answer code language (that way we can do syntax highlighting for them when they answer the question). The question will be displayed using html. Use <h2> for the question and <x> some code </x> when you want to include code in the question. The following languages are available for user response syntax highlighting: ${languageMap.keys.join(', ')}. Unless the user has said otherwise, return at most 7 flashcards. Avoid duplicating the following questions: ${existingQuestions.join(', ')}. And while the question is to be in html, the answer should be in either plain text or the code language, no markup. If there needs to be code and explanation, use code comments for explanation.',
        role: OpenAIChatMessageRole.user,
      ),
    ];

    final stream = OpenAI.instance.chat.createStream(
      model: 'gpt-4o',
      messages: messages,
      stream: true,
      responseFormat: {
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
          },
        },
      },
    );

    StringBuffer buffer = StringBuffer();

    stream.listen((event) {
      final content = event.choices.first.delta.content;
      if (content != null) {
        buffer.write(content);
        onChunkReceived(content);
      }
    }, onDone: () {
      final jsonResponse = jsonDecode(buffer.toString());
      final flashcards = jsonResponse['flashcards'] as List;
      final flashcardList = flashcards.map((flashcard) {
        return FlashCard(
          id: 0,
          question: flashcard['question'],
          answer: flashcard['answer'],
          answerInputLanguage: flashcard['language'],
        );
      }).toList();

      // Use the flashcardList as needed
    }, onError: (error) {
      print('Error: $error');
    });
  }
}
