import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/v1_chat_completions.dart';
// import datastore
import 'package:Structure/src/data_store.dart';
import 'package:Structure/src/utils/assistant_actions/assistant_actions.dart';
import 'chat_bubbles/i_chat_bubble.dart';
import 'package:Structure/src/utils/surrealdb/surrealdb_client.dart';

class ChatWidget extends StatefulWidget {
  final ChatHistory chatHistory;
  final bool isPage;
  final Future<String> Function()? getContext;
  final List<AssistantAction> assistantActions;
  const ChatWidget({
    super.key,
    required ChatHistory chatHistory,
    this.isPage = false,
    this.getContext,
    this.assistantActions = const [],
  }) : chatHistory = chatHistory;

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final V1ChatCompletions _chatCompletions = V1ChatCompletions();
  late ChatHistory _chatHistory;
  final ScrollController _scrollController = ScrollController();
  ChatCompletionAPI _selectedApi = ChatCompletionAPI.OpenAI;

  @override
  void initState() {
    super.initState();
    _chatHistory = widget.chatHistory;
    _selectedApi =
        Settings.getPreferredChatCompletionAPI() ?? ChatCompletionAPI.OpenAI;
  }

  Future<T> _sendMessage<T>(
      String userMessage, AssistantAction? assistantAction) async {
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

    // Use V1ChatCompletions to send the message
    final result = await _chatCompletions.sendMessage(
      userMessage: userMessage,
      systemPrompt: assistantAction?.systemPrompt(),
      getContext: widget.getContext,
      assistantAction: assistantAction,
      onChunkReceived: (chunk) async {
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
      // Assuming a response schema exists
      onError: (error) async {
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
      api: _selectedApi,
      chatHistory: _chatHistory.messages,
    );
    return result;
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
          if (message.chatBubbleType == 'query') {
            return ChatBubble(
              message: message,
              onDelete: () {
                setState(() {
                  _chatHistory.removeMessage(message);
                  _chatHistory.save();
                });
              },
              onExecuteQuery: (query) async {
                // execute the query
                final result = await DB().query(query: query);
                // add the result to the chat history
                final prettyJson = JsonEncoder.withIndent('  ').convert(result);
                _chatHistory.addMessage(ChatMessage(
                    id: 0,
                    role: 'assistant',
                    content: prettyJson,
                    chatBubbleType: 'query_result'));
                setState(() {
                  _chatHistory.save();
                });
              },
            );
          } else {
            return ChatBubble(
              message: message,
              onDelete: () {
                setState(() {
                  _chatHistory.removeMessage(message);
                  _chatHistory.save();
                });
              },
            );
          }
        });

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
      child: Column(
        children: [
          RawKeyboardListener(
            focusNode: focusNode,
            onKey: (event) {
              if (event.isControlPressed &&
                  event.logicalKey == LogicalKeyboardKey.enter) {
                if (controller.text.isNotEmpty) {
                  _sendMessage(controller.text, null);
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
                      _sendMessage(controller.text, null);
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widget.assistantActions.map((action) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _sendMessage(controller.text, action);
                      // Pass the assistant action here
                      // Example: _sendMessageWithAction(controller.text, action);
                      controller.clear();
                    }
                  },
                  child: Text(
                      "(${action.shortcutKey}) ${action.buttonText ?? "Unnamed Action"}"),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
          DropdownButton<ChatCompletionAPI>(
            value: _selectedApi,
            dropdownColor: Color(0xFF2C2C2C),
            items: ChatCompletionAPI.values.map((ChatCompletionAPI api) {
              return DropdownMenuItem<ChatCompletionAPI>(
                value: api,
                child: Text(api.toString().split('.').last,
                    style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (ChatCompletionAPI? newValue) {
              Settings.setPreferredChatCompletionAPI(newValue!);
              setState(() {
                _selectedApi = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}


// class ChatMessageResponseSchema extends StructuredResponse<ChatMessage> {
//   @override
//   Future<ChatMessage?> decode(
//       String response, Future<void> Function(String)? onError) async {
//     // Implement a basic decoding logic
//     final Map<String, dynamic> json = jsonDecode(response);
//     return ChatMessage(
//         id: 0,
//         role: json['role'] ?? 'assistant',
//         content: json['content'] ?? '',
//         embedding: null) ?? null;
//   }

//   @override
//   String toJsonString() {
//     return '{"role": "string", "content": "string"}';
//   }

//   @override
//   String systemPrompt() {
//     return 'Please provide a response in JSON format with role and content.';
//   }
//   @override
//   Map<String, dynamic>? get responseFormat => null;
// }
