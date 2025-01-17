import 'package:Structure/src/data_types/code_editor/language_option.dart';
import 'dart:convert';
import 'schemas.dart';

class GradedFlashcardResponse extends StructuredResponse<GradedFlashcard> {
  @override
  final responseFormat = {
    "type": "json_schema",
    "json_schema": {
      "name": "GradedFlashcardResponse",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "gradedFlashcard": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "analysis": {"type": "string"},
                "grade": {"type": "integer"},
                "flashCardId": {"type": "integer"}
              },
              "required": ["analysis", "grade", "flashCardId"],
              "additionalProperties": false
            }
          }
        },
        "required": ["gradedFlashcard"],
        "additionalProperties": false
      }
    }
  };
  @override
  Future<GradedFlashcard?> decode(
      String response, Future<void> Function(String)? onError) async {
    late Map<String, dynamic> jsonResponse;
    try {
      try {
        jsonResponse = jsonDecode(response);
      } catch (e) {
        await onError?.call(
            'Error decoding graded flashcard with jsonDecode function in graded_flashcard.dart: $e, flashcard: $response');
      }
      final gradedFlashcard = jsonResponse['gradedFlashcard'][0] ?? "";
      return GradedFlashcard(
          analysis: gradedFlashcard['analysis'],
          grade: gradedFlashcard['grade'],
          flashCardId: gradedFlashcard['flashCardId']);
    } catch (e) {
      await onError?.call(
          'Error decoding graded flashcard in graded_flashcard.dart: $e, flashcard: $response');
    }
    return null;
  }
}

class GradedFlashcard {
  final String analysis;
  final int grade;
  final int flashCardId;
  GradedFlashcard(
      {required this.analysis, required this.grade, required this.flashCardId});
}
