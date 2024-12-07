import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart'; // Replace with your preferred language.

import '../../data_store.dart';
import '../md/md_viewer.dart';
import 'flash_card_result_screen.dart';
import 'flash_card_result.dart';
import '../code_editor/language_selector.dart';
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
  late CodeController _codeController;
  final FocusNode _focusNode = FocusNode(); // Create a FocusNode for the editor

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '', // Empty initial user input
      language: dart, // Syntax highlighting for Dart
    );

    // Request focus as soon as the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Clean up the FocusNode
    super.dispose();
  }

  void _submitAnswer() {
    final userAnswer = _codeController.text;
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
    widget.onAnswerSubmitted(FlashCardResult.skipped); // Callback for skip
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hides the back button
        title: const Text('Flash Card', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1, // Responsive padding
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
              
              Expanded(
                child: CodeTheme(
                  data: CodeThemeData(styles: monokaiSublimeTheme),
                  child: CodeField(
                    controller: _codeController,
                    focusNode: _focusNode, // Attach the FocusNode
                    gutterStyle: GutterStyle.none, // Removes line numbers, errors
                  ),
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
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text('Skip'),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
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
