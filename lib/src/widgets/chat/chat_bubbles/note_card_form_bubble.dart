import 'package:flutter/material.dart';
import 'package:Structure/src/data_store.dart';
import 'i_chat_bubble.dart';

class NoteCardFormBubble extends StatefulWidget {
  final ChatMessage message;
  final Function onSubmit;
  final VoidCallback onDelete;
  final List<IconButton>? actionButtons;
  const NoteCardFormBubble({
    super.key,
    required this.message,
    required this.onSubmit,
    required this.onDelete,
    this.actionButtons,
  });

  @override
  State<NoteCardFormBubble> createState() => _NoteCardFormBubbleState();
}

class _NoteCardFormBubbleState extends State<NoteCardFormBubble> {
  @override
  Widget build(BuildContext context) {
    return ChatBubble(
        message: widget.message,
        onDelete: widget.onDelete,
        actionButtons: widget.actionButtons ?? [],
        displayContentBuilder: (context) => _bubbleDisplay(context));
  }
  Widget _bubbleDisplay(BuildContext context)  {
    return Column(children: [
      // int form field "How many flashcards?"
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
        decoration: InputDecoration(labelText: "How many flashcards would you like to create?"),
        validator: (value) {
          if(value == null || value.isEmpty){
            return "Please enter a valid number";
          }
          return null;
        },
        onFieldSubmitted: (value) {
          widget.onSubmit(value);
        },
      ),
    ],);
  }
}

