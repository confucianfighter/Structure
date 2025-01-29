import 'package:Structure/src/data_store.dart';
import 'package:Structure/src/utils/assistant_actions/assistant_actions.dart';
import 'package:Structure/src/data_types/code_editor/language_option.dart';
import 'dart:core';

class FlashcardAssistant extends AssistantAction<List<FlashCard>> {
  Subject subject;
  // constructor
  FlashcardAssistant(
      {required this.subject,
      super.onResultGenerated,
      super.shortcutKey,
      super.buttonText}) {
    super.shortcutKey = shortcutKey;
    super.buttonText = buttonText;
  }
  @override
  final responseFormat = {
    "type": "json_schema",
    "json_schema": {
      "name": "FlashcardResponse",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "flashcards": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "question": {"type": "string"},
                "answer": {"type": "string"},
                "hint": {"type": "string"},
                "language": {
                  "type": "string",
                  "enum": languageMap.keys.toList()
                }
              },
              "required": ["question", "answer", "hint", "language"],
              "additionalProperties": false,
            },
          },
        },
        "required": ["flashcards"],
        "additionalProperties": false,
      }
    }
  };
  @override
  Future<List<FlashCard>?> decode(
      String response, Future<void> Function(String)? onError) async {
    try {
      final jsonResponse = jsonDecode(response);
      final flashcards = jsonResponse['flashcards'] as List;
      return flashcards
          .map((flashcard) => FlashCard(
                id: 0,
                question: flashcard['question'],
                answer: flashcard['answer'],
                answerInputLanguage: flashcard['language'],
                hint: flashcard['hint'] ?? '',
              ))
          .toList();
    } catch (e) {
      await onError?.call(
          'Error decoding flashcards as a list of flashcards in generated_flashcards.dart: $e');
    }
    return null;
  }

  @override
  String systemPrompt() {
    // get all cards that have a matching subjectfinal existingCards = _flashCards

    final existingCards = subject
        .getFlashcards()
        ?.map((fc) =>
            "Question:${fc.question}, Answer: ${fc.answer} grade history: ${fc.grades.join(', ')}")
        .toList()
        .join(', ');
    return """You are a clever and helpful tutor on all manner of subjects. 
          Your relationship with the user is like Aristotle to Alexander the great. 
          Create a list of flashcards based on what your beloved student has asked. 
          Each flashcard should have a question, an answer, a clever hint, and an answer code language (that way we can do syntax highlighting for them when they answer the question). 
          The question and answer will be displayed using html. 
          Use <h2> for the question and <x> some code </x> when you want to include code. 
          I'm processing <x> as a special tag for code and using auto syntax highlighting. 
          The following languages are available for user response syntax highlighting: ${languageMap.keys.join(', ')}. 
          Unless the user has said otherwise, return at most 7 flashcards. 
          Avoid duplicating the following questions: 
          $existingCards. 
          Times correct and times incorrect on each card should be a good indicator of how well the user knows the subject.
          And while the question is to be in html, the answer should be in either plain text or the code language, no markup. 
          If there needs to be code and explanation, use code comments for explanation.
          The current subject is ${subject.name} having to do with ${subject.description}""";
  }

  @override
  Future<void> processResponseObject(List<FlashCard> response) async {
    List<int> ids = [];
    for (var flashcard in response) {
      flashcard.subject.target = subject;
      flashcard.id = 0;
      int id = Data().store.box<FlashCard>().put(flashcard);
      ids.add(id);
    }
    // get the flashcards from the ids
    List<FlashCard> flashcards = [];
    for (var id in ids) {
      FlashCard? flashcard = Data().store.box<FlashCard>().get(id);
      if (flashcard != null) flashcards.add(flashcard);
    }
    onResultGenerated?.call(flashcards);
  }
}
