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
    required ChatHistory chatHistory,
    this.isPage = false,
    this.getContext,
  }) : chatHistory = chatHistory;

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ChatAssistant _chatAssistant = ChatAssistant();
  late ChatHistory _chatHistory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatHistory = widget.chatHistory;
  }

  void _sendMessage(String userMessage) async {
    final userChatMessage = ChatMessage(
      id: 0,
      role: 'user',
      content: userMessage,
    );

    setState(() {
      _chatHistory.addMessage(userChatMessage);
      _chatHistory.save();
    });

    // Scroll the user message to the top
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTop();
    });

    // Create a single assistant message
    final assistantMessage = ChatMessage(
      id: 0,
      role: 'assistant',
      content: '',
    );

    setState(() {
      _chatHistory.addMessage(assistantMessage);
      _chatHistory.save();
    });

    // Pass the entire message history and context to the assistant
    await _chatAssistant.sendMessage(
      _chatHistory.messages.toList(),
      widget.getContext != null ? await widget.getContext!() : '',
      (chunk) async {
        setState(() {
          // Append new content to the most recent message in the chat history
          if (_chatHistory.messages.last.role == 'assistant') {
            _chatHistory.messages.last.content += chunk;
            _chatHistory.messages.last.save();
            _chatHistory.save();
          }
        });

        // Scroll to the bottom of the reply if it gets too long
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottomIfNeeded();
        });
      },
      (error) async {
        final errorMessage = ChatMessage(
          id: 0,
          role: 'system',
          content: error,
        );
        setState(() {
          _chatHistory.addMessage(errorMessage);
          _chatHistory.save();
        });
      },
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScrollPosition = _scrollController.position.pixels;
      if (currentScrollPosition < maxScrollExtent) {
        _scrollController.animateTo(
          maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatContent = ListView.builder(
      controller: _scrollController,
      itemCount: _chatHistory.messages.length,
      itemBuilder: (context, index) {
        final message = _chatHistory.messages[index];
        return ChatBubble(
          message: message,
          onDelete: () {
            setState(() {
              _chatHistory.removeMessage(message);
              _chatHistory.save();
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
                      _chatHistory.messages.clear();
                      _chatHistory.save();
                    });
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                _buildInputArea(),
                Expanded(child: chatContent),
              ],
            ),
            backgroundColor: Color(0xFF1B1B1B),
          )
        : Container(
            color: Color(0xFF1B1B1B),
            child: Column(
              children: [
                _buildInputArea(),
                Expanded(child: chatContent),
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
