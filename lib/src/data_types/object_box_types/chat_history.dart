import '../../data_store.dart';

@Entity()
class ChatHistory {
  @Id()
  int id = 0;

  @Backlink()
  final messages = ToMany<ChatMessage>();

  ChatHistory({
    required this.id,
  });

  // Add a message to the chat history
  void addMessage(ChatMessage message) {
    messages.add(message);
    message.chatHistory.target = this;
    Data().store.box<ChatMessage>().put(message);
  }

  // Remove a message from the chat history
  void removeMessage(ChatMessage message) {
    messages.remove(message);
    Data().store.box<ChatMessage>().remove(message.id);
  }

  // Get all messages as a list
  List<ChatMessage> getAllMessages() {
    return messages.toList();
  }

  // Read from ObjectBox
  

  // Write to ObjectBox
  void save() {
    Data().store.box<ChatHistory>().put(this);
  }
}
