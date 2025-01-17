import 'package:Structure/src/data_store.dart';
import 'package:Structure/src/utils/response_schemas/schemas.dart';
import 'package:Structure/src/data_types/code_editor/language_option.dart';
import 'dart:convert';
class GeneratedFlashcardsSchema extends StructuredResponse<List<FlashCard>> {
  @override
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
                  "hint": {"type": "string"},
                  "language": {
                    "type": "string",
                    "enum": languageMap.keys.toList()
                  }
                },
                "required": ["question", "answer", "hint", "language"],
                "additionalProperties": false,
              },
            },
          },
          "required": ["flashcards"],
          "additionalProperties": false,
        }
      }
    };
    @override
    Future<List<FlashCard>?> decode(String response, Future<void> Function(String)? onError) async {
      try {
        final jsonResponse = jsonDecode(response);
        final flashcards = jsonResponse['flashcards'] as List;
        return flashcards
            .map((flashcard) => FlashCard(
                  id: 0,
                  question: flashcard['question'],
                  answer: flashcard['answer'],
                  answerInputLanguage: flashcard['language'],
                  hint: flashcard['hint'] ?? '',
                ))
            .toList();
      }
      catch (e) {
        await onError?.call('Error decoding flashcards as a list of flashcards in generated_flashcards.dart: $e');
      }
      return null;
    }
    
     
}
