import 'package:objectbox/objectbox.dart';

@Entity()
class Countdown {
  @Id(assignable: true)
  int id = 0;
  
  int remainingSeconds;

  Countdown({required this.id, required this.remainingSeconds});
}