import 'package:flutter/material.dart';

import '../../data_store.dart';
import 'flash_card_result_screen.dart';
import 'flash_card_result.dart';
import '../code_editor/code_editor.dart';
import '../html_viewer/html_viewer.dart';
import '../chat/chat.dart';
import 'package:Structure/gen/assets.gen.dart';

class FlashCardWidget extends StatefulWidget {
  final FlashCard flashCard;
  final bool testMode;
  final Function(FlashCardResult) onAnswerSubmitted;

  const FlashCardWidget({
    super.key,
    required this.flashCard,
    required this.testMode,
    required this.onAnswerSubmitted,
  });

  @override
  _FlashCardWidgetState createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  final GlobalKey<CodeEditorWidgetState> _editorKey = GlobalKey();
  var _userAnswer = '';
  final bool _showHint = false;
  bool _showChat = false;

  void _submitAnswer() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          flashCard: widget.flashCard,
          userAnswer: _userAnswer,
          onAnswerSubmitted: widget.onAnswerSubmitted,
        ),
      ),
    );
  }

  void _skipAnswer() {
    Navigator.pop(context);
    widget.onAnswerSubmitted(FlashCardResult.skipped);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Flash Card', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.15,
            vertical: 16.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: HTMLViewer(
                        initialText: _showHint
                            ? widget.flashCard.answer
                            : widget.flashCard.question,
                        cssPath: Assets.css.bootstrap.bootstrapSlateMin,
                        highlightJsCssPath: Assets.css.highlight.agate,
                        onLanguageChanged: null,
                        showEditButton: false,
                        onChanged: null,
                        language: 'html',
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Your Answer:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12.0),
                    Expanded(
                      child: CodeEditorWidget(
                        key: _editorKey,
                        initialText: '',
                        language: widget.flashCard.answerInputLanguage,
                        onChanged: (answer) {
                          _userAnswer = answer;
                        },
                        onLanguageChanged: null,
                        isFullScreen: false,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _skipAnswer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                            ),
                            child: const Text('Skip'),
                          ),
                          const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: _submitAnswer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_showChat)
                SizedBox(
                  width: screenWidth * 0.3,
                  child: ChatWidget(
                    chatHistory: widget.flashCard.chatHistory.target ??
                        ChatHistory(id: 0),
                    isPage: false,
                    getContext: () async {                      
                          final subjectName = widget.flashCard.subject.target?.name ?? 'unknown subject';                          
                          final message ='You are a very clever tutor. The current subject is $subjectName, the current flashcard being reviewed is ${widget.flashCard.question}';
                      return message;
                    },
                  ),
                ),
              IconButton(
                icon:
                    Icon(_showChat ? Icons.chat_bubble : Icons.question_answer),
                onPressed: () {
                  setState(() {
                    _showChat = !_showChat;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
