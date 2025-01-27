import 'dart:math';
import 'package:flutter/material.dart';
import 'package:Structure/src/data_store.dart';
import 'package:Structure/src/widgets/flash_cards/flash_card.dart';
import 'package:Structure/src/widgets/flash_cards/flash_card_result.dart';

class FlashCardStackManager {
  final Subject subject;
  final int numberOfRandomCards;
  final int gradeThreshold;
  final List<FlashCard> _flashCards;
  final List<FlashCard> _stack = [];
  final List<FlashCard> _poppedCards = [];
  final VoidCallback onFinished;
  final NavigatorState navigator;
  final List<Widget> _poppedCardWidgets = [];

  FlashCardStackManager({
    required this.subject,
    required this.numberOfRandomCards,
    required this.gradeThreshold,
    required this.navigator,
    required this.onFinished,
  }) : _flashCards = Data()
            .store
            .box<FlashCard>()
            .query(FlashCard_.subject.equals(subject.id))
            .build()
            .find() {
    _initializeStack();
  }

  void _initializeStack() {
    final random = Random();
    final indices = <int>{};

    while (indices.length < numberOfRandomCards &&
        indices.length < _flashCards.length) {
      indices.add(random.nextInt(_flashCards.length));
    }

    for (var index in indices) {
      _stack.add(_flashCards[index]);
    }
  }
  void AddCards(List<FlashCard> cards){
    _stack.addAll(cards);
  }
  void play() {
    if (_stack.isEmpty) {
      navigator.pop();
      return;
    }

    final flashCard = _stack.removeLast();
    
    navigator.push(
      MaterialPageRoute(
        builder: (context) => FlashCardWidget(
          flashCard: flashCard,
          testMode: true,
          manager: this,
          onAnswerSubmitted: (result) {
            _poppedCards.add(flashCard);
            navigator.pop();
            if (result == FlashCardResult.incorrect) {
              _stack.insert(0, flashCard); // Reinsert at the beginning
            }
            if (_stack.isNotEmpty) play(); // Continue to the next card
          },
          onBack: () {
            // all I need to do is modify the stacks and then play again
            if (_poppedCards.isNotEmpty) {
              _stack.add(flashCard);
              _poppedCards.remove(flashCard);
              if (_poppedCards.isNotEmpty) {
                final card = _poppedCards.removeLast();
                _stack.add(card);
              }

              play();
            } else {
              navigator.pop();
            }
          },
        ),
      ),
    );
  }
}
