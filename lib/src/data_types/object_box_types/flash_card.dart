import '../../data_store.dart';

@Entity()
class FlashCard {
  @Id()
  int id;
  String type = 'essay_question';
  String correctAnswerDislpayLanguage = 'markdown';
  String questionDisplayLanguage = 'markdown';
  String answerInputLanguage = 'plainText';
  String question;
  String answer;
  int timesCorrect = 0;
  int timesIncorrect = 0;
  int userRating = 0;
  ToOne<Subject> subject = ToOne<Subject>();

  FlashCard({
    required this.id,
    required this.question,
    required this.answer,
  });
}
