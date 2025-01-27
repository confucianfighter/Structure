import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Structure/src/data_store.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback onDelete;
  final Widget Function(BuildContext context)? displayContentBuilder;
  List<IconButton>? actionButtons;
  final Future<void> Function(String)? onExecuteQuery;
  // if a make a chat bubble that requires a special widget, then I need to either somehow make it ephemeral
  // in the chat widget, or have a type in the database. I like the idea of it being ephemeral.
  // Perhaps there would be separate action bubbles?
  // Perhaps it would be saved as text only
  ChatBubble({
    super.key,
    required this.message,
    required this.onDelete,
    this.actionButtons,
    this.displayContentBuilder,
    this.onExecuteQuery,
  });
  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  ChatMessage get message => widget.message;
  List<IconButton> _actionButtons = [];
  @override
  void initState() {
    super.initState();
    _actionButtons = [
      if (message.chatBubbleType == 'query')
        IconButton(
          icon: Icon(Icons.play_arrow, color: Color(0xFFB0B0B0)),
          onPressed: () {
            widget.onExecuteQuery!(message.content);
          },
        ),
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
        onPressed: widget.onDelete,
      ),
    ];
    if (widget.actionButtons != null) {
      _actionButtons.addAll(widget.actionButtons!);
    }
  }

  Widget _displayContentWithInnerBorder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: message.role == 'system' ? Colors.red[900] : Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Text(
        message.content,
        style: TextStyle(color: Color(0xFFB0B0B0)),
      ),
    );
  }

  Widget DisplayContent(BuildContext context) {
    if (widget.displayContentBuilder != null) {
      return widget.displayContentBuilder!(context);
    } else {
      return Text(
        message.content,
        style: TextStyle(color: Color(0xFFB0B0B0)),
      );
    }
  }

  Widget _displayActionButtons(BuildContext context) {
    return Row(children: [
      ..._actionButtons.map((button) => button),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Stack(
        children: [
          _displayContentWithInnerBorder(context),
          Positioned(
            top: 0,
            right: 0,
            child: _displayActionButtons(context),
          ),
        ],
      ),
    );
  }
}
