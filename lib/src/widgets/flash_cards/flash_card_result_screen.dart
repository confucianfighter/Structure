import 'package:flutter/material.dart';
import '../../data_store.dart';
import '../md/md_viewer.dart';
import 'flash_card_result.dart';
class ResultScreen extends StatefulWidget {
  final FlashCard flashCard;
  final String userAnswer;
  final Function(FlashCardResult) onAnswerSubmitted;

  const ResultScreen({
    super.key,
    required this.flashCard,
    required this.userAnswer,
    required this.onAnswerSubmitted,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _rating = 0;

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    widget.flashCard.userRating = rating;
    Data().store.box<FlashCard>().put(widget.flashCard);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Review Your Answer', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1, // Dynamic padding
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Answer:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8.0),
                MdViewer(content: widget.userAnswer),
                const Divider(height: 32.0),
                const Text(
                  'Correct Answer:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8.0),
                MdViewer(content: widget.flashCard.answer),
                const Divider(height: 32.0),
                const Text(
                  'Were you correct?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.flashCard.timesIncorrect++;
                        Data().store.box<FlashCard>().put(widget.flashCard);
                        Navigator.pop(context);
                        widget.onAnswerSubmitted(FlashCardResult.incorrect);
                      },
                      child: const Text('Incorrect'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.flashCard.timesCorrect++;
                        Data().store.box<FlashCard>().put(widget.flashCard);
                        Navigator.pop(context);
                        widget.onAnswerSubmitted(FlashCardResult.correct);
                      },
                      child: const Text('Correct'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Rate Helpfulness:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _rating ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        _setRating(index + 1);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
