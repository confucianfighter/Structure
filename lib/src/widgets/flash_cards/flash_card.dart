import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

import '../../data_store.dart';
import '../md/md_viewer.dart';
import 'flash_card_result_screen.dart';
import 'flash_card_result.dart';
import '../code_editor/code_editor.dart'; // Import the new widget

class FlashCardWidget extends StatefulWidget {
  final FlashCard flashCard;
  final bool testMode;
  final Function(FlashCardResult) onAnswerSubmitted;

  const FlashCardWidget({
    Key? key,
    required this.flashCard,
    required this.testMode,
    required this.onAnswerSubmitted,
  }) : super(key: key);

  @override
  _FlashCardWidgetState createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  final GlobalKey<CodeEditorWidgetState> _editorKey = GlobalKey();

  void _submitAnswer() {
    final userAnswer = _editorKey.currentState?.getCode() ?? '';
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          flashCard: widget.flashCard,
          userAnswer: userAnswer,
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
            horizontal: screenWidth * 0.1,
            vertical: 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MdViewer(content: widget.flashCard.question),
              const SizedBox(height: 24.0),
              const Text(
                'Your Answer:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12.0),

              // Insert our new code editor widget here
              Expanded(
                child: CodeEditorWidget(
                  key: _editorKey,
                  initialCode: '', // or prefill if needed
                  language: widget.flashCard.answerLanguage,
                  // onLanguageChanged: (lang) { ... if needed }
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
      ),
    );
  }
}
