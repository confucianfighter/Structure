import 'package:Structure/src/data_store.dart';
import 'package:flutter/material.dart';
import 'package:Structure/src/widgets/chat/chat_bubbles/i_chat_bubble.dart';

enum ChatBubbleType {
  text,
  generated_flashcards,
  generated_surrealdb_query,
}

@Entity()
class ChatMessage {
  @Id()
  int id = 0;
  String role;
  String content;
  String? embedding; // Optional field for future use
  String? chatBubbleType;
  String? data;
  final chatHistory = ToOne<ChatHistory>();

  ChatMessage(
      {required this.id,
      required this.role,
      required this.content,
      this.embedding,
      this.chatBubbleType = "text"});

  void save() {
    Data().store.box<ChatMessage>().put(this);
  }

  bool verifyWidgetType(String type) {
    return ChatBubbleType.values.any((e) => e.name == type);
  }

  ChatBubbleType? determineChatBubbleType(String name) {
    return ChatBubbleType.values.firstWhere((e) => e.name == chatBubbleType);
  }

  Widget? getChatBubbleWidget(Function() onDelete, Function(String)? onError) {
    if (!verifyWidgetType(chatBubbleType!)) {
      if (onError != null)
        onError("chatBubbleType not found \\${chatBubbleType}");
      else
        throw Exception("chatBubbleType not found \\${chatBubbleType}");
      return null;
    }
    switch (determineChatBubbleType(chatBubbleType!) ?? ChatBubbleType.text) {
      case ChatBubbleType.text:
        return ChatBubble(message: this, onDelete: onDelete);
      case ChatBubbleType.generated_flashcards:
        // if I do it this way...nah, need to extend the class, this file could get messy.
        // this means that the text needs to contain the ids.

        // Add logic for generated_flashcards type
        break;
      case ChatBubbleType.generated_surrealdb_query:
        // Add logic for generated_surrealdb_query type
        break;
    }
    return null;
  }
}
