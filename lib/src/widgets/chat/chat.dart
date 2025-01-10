import 'package:flutter/material.dart';
import '../../data_types/object_box_types/chat_message.dart';
import '../../data_types/object_box_types/chat_history.dart';
import 'package:flutter/services.dart';
import '../../utils/chat_assistant.dart';

class ChatWidget extends StatefulWidget {
  final ChatHistory chatHistory;
  final bool isPage;
  final Future<String> Function()? getContext;

  const ChatWidget({
    super.key,
    required this.chatHistory,
    this.isPage = false,
    this.getContext,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ChatAssistant _chatAssistant = ChatAssistant();

  void _sendMessage(String userMessage) async {
    final context = widget.getContext != null ? widget.getContext!() : '';

    final userChatMessage = ChatMessage(
      id: 0,
      role: 'user',
      content: userMessage,
    );

    setState(() {
      widget.chatHistory.addMessage(userChatMessage);
      widget.chatHistory.save();
    });

    // Create a single assistant message
    final assistantMessage = ChatMessage(
      id: 0,
      role: 'assistant',
      content: '',
    );

    setState(() {
      widget.chatHistory.addMessage(assistantMessage);
      widget.chatHistory.save();
    });

    // Pass the entire message history and context to the assistant
    await _chatAssistant.sendMessage(
      widget.chatHistory.messages.toList(),
      widget.getContext != null ? await widget.getContext!() : '',
      (chunk) async {
        setState(() {
          // Append new content to the existing assistant message
          assistantMessage.content += chunk;
          widget.chatHistory.save();
        });
      },
      (error) async {
        final errorMessage = ChatMessage(
          id: 0,
          role: 'system',
          content: error,
        );
        setState(() {
          widget.chatHistory.addMessage(errorMessage);
          widget.chatHistory.save();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatContent = ListView.builder(
      itemCount: widget.chatHistory.messages.length,
      itemBuilder: (context, index) {
        final message = widget.chatHistory.messages[index];
        return ChatBubble(
          message: message,
          onDelete: () {
            setState(() {
              widget.chatHistory.removeMessage(message);
              widget.chatHistory.save();
            });
          },
        );
      },
    );

    return widget.isPage
        ? Scaffold(
            appBar: AppBar(
              title: Text('Chat'),
              backgroundColor: Color(0xFF1B1B1B),
              actions: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      widget.chatHistory.messages.clear();
                      widget.chatHistory.save();
                    });
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(child: chatContent),
                _buildInputArea(),
              ],
            ),
            backgroundColor: Color(0xFF1B1B1B),
          )
        : Container(
            color: Color(0xFF1B1B1B),
            child: Column(
              children: [
                Expanded(child: chatContent),
                _buildInputArea(),
              ],
            ),
          );
  }

  Widget _buildInputArea() {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RawKeyboardListener(
        focusNode: focusNode,
        onKey: (event) {
          if (event.isControlPressed &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (controller.text.isNotEmpty) {
              _sendMessage(controller.text);
              controller.clear();
            }
          }
        },
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _sendMessage(controller.text);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: message.role == 'system'
                  ? Colors.red[900]
                  : Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Text(
              message.content,
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.copy, color: Color(0xFFB0B0B0)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFFB0B0B0)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
