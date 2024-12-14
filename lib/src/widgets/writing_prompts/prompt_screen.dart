import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data_store.dart';

class WritingPromptScreen extends StatefulWidget {
  final List<WritingPrompt> promptList;
  final int index;

  const WritingPromptScreen({
    super.key,
    required this.index,
    required this.promptList,
  });

  @override
  _WritingPromptScreenState createState() => _WritingPromptScreenState();
}

class _WritingPromptScreenState extends State<WritingPromptScreen> {
  late WritingPrompt _currentPrompt;
  late List<WritingPrompt> _promptList;
  WritingPromptAnswer? _currentAnswer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPrompt = widget.promptList.elementAt(widget.index);
    _promptList = widget.promptList;
    _currentAnswer = null;
  }

  void _submitAnswer() {
    final answerText = _controller.text.trim();
    if (answerText.isEmpty) return;

    // Save the answer to the current prompt
    final newAnswer = WritingPromptAnswer(
      answer: answerText,
      dateAnswered: DateTime.now(),
    );
    newAnswer.writingPrompt.target = _currentPrompt;

    // Update last answered time
    setState(() {
      if(_currentAnswer != null){
        newAnswer.id = _currentAnswer!.id;
      }
      else{
        newAnswer.id = Data().store.box<WritingPromptAnswer>().put(newAnswer);
        _currentPrompt.addAnswer(newAnswer);
      }
      _currentAnswer = newAnswer;
      _currentPrompt.lastTimeAnswered = DateTime.now();
    });

    // Load the next prompt from the queue, or exit if none remain
    // say length is 4 and we are at index 3, length would be 5 if there is another prompt remaining.
    if (_promptList.length > widget.index + 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WritingPromptScreen(
            index: widget.index + 1,
            promptList: _promptList,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Markdown(
                    data: _currentPrompt.prompt,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type your answer here...",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submitAnswer(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _submitAnswer,
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
