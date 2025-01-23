import '../../data_store.dart';
import 'i_table.dart';

@Entity()
class FlashCard extends ITable<FlashCard> {
  @Id()
  int id;
  String type = 'essay_question';
  String correctAnswerDislpayLanguage = 'html';
  String questionDisplayLanguage = 'html';
  String answerInputLanguage = 'plainText';
  String question;
  String answer;
  String hint = '';
  int timesCorrect = 0;
  int timesIncorrect = 0;
  int userRating = 0;
  List<int> grades = [];
  String analysis = '';
  ToOne<Subject> subject = ToOne<Subject>();
  ToOne<ChatHistory> chatHistory = ToOne<ChatHistory>();

  FlashCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.answerInputLanguage,
    this.hint = '',
  });
  @override
  int getId() {
    return id;
  }
}
