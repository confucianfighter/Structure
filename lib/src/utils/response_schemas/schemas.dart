export 'generated_flashcards.dart';
export 'graded_flashcard.dart';
export 'generated_surrealdb_query.dart';
export 'dart:convert';
import 'dart:convert';

abstract class StructuredResponse<T> {
  Map<String, dynamic> get responseFormat;
  Future<T?> decode(String response, Future<void> Function(String)? onError);
  String toJsonString() => jsonEncode(responseFormat);
}
