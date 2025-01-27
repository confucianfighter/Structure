export 'generated_flashcards.dart';
export 'graded_flashcard.dart';
export 'generated_surrealdb_query.dart';
export 'dart:convert';
import 'dart:convert';
import 'package:flutter/material.dart';

abstract class AssistantAction<T> {
  String? shortcutKey;
  String? buttonText;
  Function(Widget)? addChatWidgetCallback;
  Function(Widget)? addFormInputCallback;
  void Function(T result)? onResultGenerated;
  AssistantAction({
    this.shortcutKey,
    this.buttonText,
    this.addChatWidgetCallback,
    this.onResultGenerated
  });
  Map<String, dynamic>? get responseFormat;
  Future<T?> decode(String response, Future<void> Function(String)? onError);
  String toJsonString() => jsonEncode(responseFormat);
  String systemPrompt();
  Future<void> processResponseObject(T response);
  
}
