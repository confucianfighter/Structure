import 'dart:ffi';

import '../../data_store.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class FlashCardSequence {
  @Id()
  int id;
  int number_of_cards;
  ToOne<Subject> subject = ToOne<Subject>();
  FlashCardSequence({
    this.id = 0,
    required this.subject,
    this.number_of_cards = 0,
  });
}
