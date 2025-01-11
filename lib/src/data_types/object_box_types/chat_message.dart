import 'package:objectbox/objectbox.dart';
import 'chat_history.dart';
import 'package:Structure/src/data_store.dart';
@Entity()
class ChatMessage {
  @Id()
  int id = 0;
  String role;
  String content;
  String? embedding; // Optional field for future use

  final chatHistory = ToOne<ChatHistory>();

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.embedding,
  });
  void save(){
    Data().store.box<ChatMessage>().put(this);
  }
}
