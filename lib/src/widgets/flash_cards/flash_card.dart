import 'package:flutter/material.dart';

import '../../data_store.dart';
import 'flash_card_result_screen.dart';
import 'flash_card_result.dart';
import '../code_editor/code_editor.dart';
import '../html_viewer/html_viewer.dart';
import '../chat/chat.dart';
import 'package:Structure/gen/assets.gen.dart';
import '../../utils/v1_chat_completions.dart';
import '../../utils/response_schemas/graded_flashcard.dart';
import '../common/star_rating_widget.dart';

class FlashCardWidget extends StatefulWidget {
  final FlashCard flashCard;
  final bool testMode;
  final Function(FlashCardResult) onAnswerSubmitted;
  final Function()? onBack;
  const FlashCardWidget({
    super.key,
    required this.flashCard,
    required this.testMode,
    required this.onAnswerSubmitted,
    this.onBack,
  });

  @override
  _FlashCardWidgetState createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  final GlobalKey<CodeEditorWidgetState> _editorKey = GlobalKey();
  var _userAnswer = '';
  bool _showHint = false;
  bool _showAnswer = false;
  bool _showResult = false;
  String _analysis = '';
  String _rawGradeResponse = '';
  GradedFlashcard? _gradedFlashcard;
  FlashCard _flashCard =
      FlashCard(id: 0, question: '', answer: '', answerInputLanguage: '');
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _flashCard = widget.flashCard;
    if (_flashCard.chatHistory.target == null) {
      _flashCard.chatHistory.target = ChatHistory(id: 0);
      _flashCard.chatHistory.target?.save();
    }
  }

  void _submitAnswer() async {
    setState(() {
      _showResult = true;
    });
    final v1ChatCompletions = V1ChatCompletions();
    final gradedFlashcardResponse = GradedFlashcardResponse();

    _gradedFlashcard = await v1ChatCompletions.sendMessage<GradedFlashcard>(
      userMessage: _userAnswer,
      getContext: () async =>
          'Question: ${_flashCard.question}\nCorrect Answer: ${_flashCard.answer}\nUser Answer: $_userAnswer',
      systemPrompt:
          'You are a friendly, clever tutor. Grade the response from 0 to 100% with a brief reasoning. An answer under 50% is incorrect. Use HTML, and emojis.',
      onChunkReceived: (chunk) async {
        setState(() {
          _rawGradeResponse += chunk;
          final match = RegExp(r'"analysis":\s*"([^"]*?)(?=",\s*"grade"\s*:|$)')
              .firstMatch(_rawGradeResponse);
          if (match != null) {
            _analysis = match.group(1) ?? '';
          }
        });
      },
      responseSchema: gradedFlashcardResponse,
      onError: (error) async {
        setState(() {
          _analysis += error.toString();
        });
      },
    );
    if (_gradedFlashcard != null) {
      _flashCard.grades.add(_gradedFlashcard!.grade);
      await _flashCard.save();
    }
  }

  void _onAnswerSubmitted() {
    widget.onAnswerSubmitted(FlashCardResult.correct);
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
      _showAnswer = false;
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
      _showHint = false;
    });
  }

  void _backToAnswerField() {
    setState(() {
      _showHint = false;
      _showAnswer = false;
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBack?.call();
          },
        ),
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
                      child: _showResult
                          ? GradedResponseWidget(
                              flashCard: _flashCard,
                              analysis: _analysis,
                              grade: _gradedFlashcard?.grade ?? 0,
                              gradeHistory: _flashCard.grades,
                              onRatingChanged: (newRating) {
                                _flashCard.userRating = newRating;
                                _flashCard.save();
                              },
                            )
                          : HTMLViewer(
                              initialText: _flashCard.question,
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
                      child: Stack(
                        children: [
                          CodeEditorWidget(
                            key: _editorKey,
                            initialText: '',
                            language: _flashCard.answerInputLanguage,
                            onChanged: (answer) {
                              _userAnswer = answer;
                            },
                            onLanguageChanged: null,
                            isFullScreen: false,
                            allowLanguageChange: false,
                          ),
                          if (!_showHint && !_showAnswer)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _toggleHint,
                                    child: const Text('Show Hint'),
                                  ),
                                  const SizedBox(width: 8.0),
                                  ElevatedButton(
                                    onPressed: _toggleAnswer,
                                    child: const Text('Show Answer'),
                                  ),
                                ],
                              ),
                            ),
                          if (_showHint || _showAnswer)
                            Positioned.fill(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          _showHint
                                              ? 'Hint: ${_flashCard.hint}'
                                              : 'Answer: ${_flashCard.answer}',
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed: _backToAnswerField,
                                        child: const Text('Back'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!_showResult)
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
                          if (_showResult) const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: _showResult
                                ? _onAnswerSubmitted
                                : _submitAnswer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                            ),
                            child: Text(_showResult ? 'Next' : 'Submit'),
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
                    chatHistory:
                        _flashCard.chatHistory.target ?? ChatHistory(id: 0),
                    isPage: false,
                    getContext: () async {
                      final subjectName =
                          _flashCard.subject.target?.name ?? 'unknown subject';
                      final userAnswer = _userAnswer.isEmpty
                          ? "The user has not yet answered."
                          : "User Answer was: $_userAnswer";
                      final correctAnswer =
                          "The correct answer is: ${_flashCard.answer}";
                      final userAnswerAnalysis = _analysis.isEmpty
                          ? ""
                          : "System Grading Analysis: $_analysis";
                      final message =
                          'You are a very clever tutor. The current subject is $subjectName, the current flashcard being reviewed is ${_flashCard.question}\n\n$userAnswer\n$correctAnswer\n$userAnswerAnalysis';
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

  void _skipAnswer() {
    widget.onAnswerSubmitted(FlashCardResult.skipped);
  }
}

class GradedResponseWidget extends StatelessWidget {
  final String analysis;
  final int grade;
  final List<int> gradeHistory;
  final Function(int) onRatingChanged;
  final FlashCard flashCard;

  const GradedResponseWidget({
    Key? key,
    required this.analysis,
    required this.grade,
    required this.gradeHistory,
    required this.onRatingChanged,
    required this.flashCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final averageGrade = gradeHistory.isNotEmpty
        ? (gradeHistory.reduce((a, b) => a + b) / gradeHistory.length)
            .toStringAsFixed(2)
        : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analysis: $analysis'),
        const SizedBox(height: 10),
        Row(
          children: List.generate(10, (index) {
            return Icon(
              Icons.star,
              color: index < (grade / 10) ? Colors.amber : Colors.grey,
            );
          }),
        ),
        Text('Grade: ${grade}%'),
        const SizedBox(height: 10),
        Text('Average Grade: $averageGrade%'),
        const SizedBox(height: 10),
        Text('Grade History: ${gradeHistory.join(', ')}'),
        const SizedBox(height: 10),
        StarRatingWidget(
          rating: flashCard.userRating,
          onRatingChanged: (newRating) {
            onRatingChanged(newRating);
          },
        ),
      ],
    );
  }
}
