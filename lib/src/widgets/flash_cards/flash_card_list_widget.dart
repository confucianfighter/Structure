import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data_store.dart';
import 'flash_card_preview.dart';
import 'flash_card_editor.dart';
import '../../utils/v1_chat_completions.dart';
import '../../utils/assistant_actions/assistant_actions.dart';
import 'package:Structure/src/utils/flash_card_stack_manager.dart';

class FlashCardListWidget extends StatefulWidget {
  const FlashCardListWidget({super.key, required this.subject});
  final Subject subject;
  @override
  _FlashCardListWidget createState() => _FlashCardListWidget();
}

class _FlashCardListWidget extends State<FlashCardListWidget> {
  bool _selectRandomCards = true;
  int _randomCardCount = 5;
  late Stream<List<FlashCard>> _streamBuilder;
  bool _isAssistantOpen = true;
  final V1ChatCompletions _flashcardAssistant = V1ChatCompletions();
  List<FlashCard> _flashCards = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _intInputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _rawResponse = '';
  int _gradeThreshold = 80;
  bool _isMultiSelectMode = false;
  final Set<int> _selectedCardIds = {};
  ChatCompletionAPI? _selectedGradingApi;
  ChatCompletionAPI? _selectedFlashcardGenerationApi;
  @override
  void initState() {
    super.initState();
    _selectedFlashcardGenerationApi =
        Settings.getPreferredFlashcardGenerationAPI() ??
            ChatCompletionAPI.OpenAI;
    _selectedGradingApi =
        Settings.getPreferredGradingAPI() ?? ChatCompletionAPI.OpenAI;

    _streamBuilder = (widget.subject.name == 'All')
        ? Data()
            .store
            .box<FlashCard>()
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find())
            .asBroadcastStream()
        : (widget.subject.name == 'Orphaned')
            ? Data()
                .store
                .box<FlashCard>()
                .query(FlashCard_.subject.isNull())
                .watch(triggerImmediately: true)
                .map((query) => query.find())
                .asBroadcastStream()
            : Data()
                .store
                .box<FlashCard>()
                .query(FlashCard_.subject.equals(widget.subject.id))
                .watch(triggerImmediately: true)
                .map((query) => query.find())
                .asBroadcastStream();
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedCardIds.clear();
      }
    });
  }

  void _toggleCardSelection(int cardId) {
    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
      } else {
        _selectedCardIds.add(cardId);
      }
    });
  }

  void _applySubjectToSelectedCards(Subject subject) {
    for (var cardId in _selectedCardIds) {
      final card = _flashCards.firstWhere((card) => card.id == cardId);
      card.subject.target = subject;
      Data().store.box<FlashCard>().put(card);
    }
  }

  void _submitAssistantRequest() async {
    final value = _textController.text;
    if (value.isNotEmpty) {
      // Fetch existing flashcards
      // Generate new flashcards
      final flashcards = await _flashcardAssistant.sendMessage<List<FlashCard>>(
        userMessage: value,
        getContext: () async {
          return "";
        },
        onChunkReceived: (content) async {
          setState(() {
            _rawResponse += content;
          });
        },
        onError: (error) async {
          print(error);
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(error),
            ),
          );
        },
        assistantAction: FlashcardAssistant(subject: widget.subject),
        api: _selectedFlashcardGenerationApi ?? ChatCompletionAPI.OpenAI,
      );
      if (flashcards != null) {
        // Add new flashcards to the data store
        setState(() {
          _rawResponse = "Success!";
        });
      } else {
        setState(() {
          _rawResponse = "Flashcards were null.\n $_rawResponse";
        });
      }
    }

    // Clear the text field
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = widget.subject.name;
    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectName FlashCards'),
        actions: [
          IconButton(
            icon: _isAssistantOpen
                ? const Icon(Icons.assistant)
                : const Icon(Icons.assistant_outlined),
            onPressed: () {
              setState(() {
                _isAssistantOpen = !_isAssistantOpen;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isAssistantOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RawKeyboardListener(
                          focusNode: _focusNode,
                          onKey: (event) {
                            if (event.isControlPressed &&
                                event.logicalKey == LogicalKeyboardKey.enter) {
                              _submitAssistantRequest();
                            }
                          },
                          child: TextFormField(
                            controller: _textController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'FlashCard Assistant',
                              hintText:
                                  'Describe the cards you would like to generate. Existing cards in this subject and your track record with them will be taken into consideration.',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _submitAssistantRequest,
                      ),
                    ],
                  ),
                  DropdownButton<ChatCompletionAPI>(
                    value: _selectedFlashcardGenerationApi,
                    dropdownColor: Color(0xFF2C2C2C),
                    items:
                        ChatCompletionAPI.values.map((ChatCompletionAPI api) {
                      return DropdownMenuItem<ChatCompletionAPI>(
                        value: api,
                        child: Text(api.toString().split('.').last,
                            style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (ChatCompletionAPI? newValue) {
                      Settings.setPreferredFlashcardGenerationAPI(newValue!);
                      setState(() {
                        _selectedFlashcardGenerationApi = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  if (_rawResponse.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      constraints: BoxConstraints(
                        maxHeight:
                            150.0, // Set a maximum height for the container
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          'Raw response: $_rawResponse',
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                // instantiate a flash card stack manager
                final flashCardStackManager = FlashCardStackManager(
                  subject: widget.subject,
                  numberOfRandomCards: _randomCardCount,
                  gradeThreshold: 80,
                  navigator: Navigator.of(context),
                  onFinished: () {},
                );
                flashCardStackManager.play();
              },
              icon: Icon(Icons.play_arrow),
              label: Text('Start Study Session'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: _selectRandomCards,
                onChanged: (bool? value) {
                  setState(() {
                    _selectRandomCards = value ?? false;
                  });
                },
              ),
              const Text('Select random cards'),
            ],
          ),
          if (_selectRandomCards)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number of random cards to select',
                    ),
                    initialValue: _randomCardCount.toString(),
                    onChanged: (value) {
                      setState(() {
                        _randomCardCount = int.tryParse(value) ?? 5;
                      });
                    },
                  ),
                  DropdownButton<ChatCompletionAPI>(
                    value: Settings.getPreferredGradingAPI() ??
                        ChatCompletionAPI.OpenAI,
                    dropdownColor: Color(0xFF2C2C2C),
                    items:
                        ChatCompletionAPI.values.map((ChatCompletionAPI api) {
                      return DropdownMenuItem<ChatCompletionAPI>(
                        value: api,
                        child: Text(api.toString().split('.').last,
                            style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (ChatCompletionAPI? newValue) {
                      Settings.setPreferredGradingAPI(newValue!);
                      setState(() {
                        _selectedGradingApi = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Grade Threshold',
                    ),
                    initialValue: _gradeThreshold.toString(),
                    onChanged: (value) {
                      setState(() {
                        _gradeThreshold = int.tryParse(value) ?? 80;
                      });
                    },
                  )
                ],
              ),
            ),
          const SizedBox(height: 8.0),
          Expanded(
            child: StreamBuilder<List<FlashCard>>(
              stream: _streamBuilder,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _flashCards = snapshot.data!;

                  return ListView.builder(
                    itemCount: _flashCards.length,
                    itemBuilder: (context, index) {
                      final flashCard = _flashCards[index];
                      return GestureDetector(
                        onLongPress: _toggleMultiSelectMode,
                        child: FlashCardPreview(
                          flashCard: flashCard,
                          isSelected: _selectedCardIds.contains(flashCard.id),
                          isMultiSelectMode: _isMultiSelectMode,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FlashCardEditor(flashCardId: flashCard.id),
                              ),
                            );
                          },
                          onDelete: () async {
                            Data().store.box<FlashCard>().remove(flashCard.id);
                          },
                          onSelect: () => _toggleCardSelection(flashCard.id),
                          onSubjectChanged: (subject) {
                            if (_isMultiSelectMode) {
                              _applySubjectToSelectedCards(subject);
                            } else {
                              flashCard.subject.target = subject;
                              Data().store.box<FlashCard>().put(flashCard);
                            }
                          },
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading FlashCards'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newFlashCard = FlashCard(
            id: 0,
            question: 'New Question',
            answer: 'New Answer',
            answerInputLanguage: 'plainText',
          );

          newFlashCard.questionDisplayLanguage = 'html';
          newFlashCard.correctAnswerDislpayLanguage = 'html';
          newFlashCard.answerInputLanguage = 'plainText';
          newFlashCard.subject.target = widget.subject;
          Data().store.box<FlashCard>().put(newFlashCard);
        },
        tooltip: 'Add FlashCard',
        child: const Icon(Icons.add),
      ),
    );
  }
}
