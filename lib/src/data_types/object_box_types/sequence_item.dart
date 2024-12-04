import 'package:objectbox/objectbox.dart';
import 'sequence_type_enum.dart';

@Entity()
class Sequence {
  int id;
  String name;
  String description;
  @Backlink()
  final slots = ToMany<SequenceItem>();

  Sequence({this.id = 0, required this.name, required this.description});
}

@Entity()
class SequenceItem {
  @Id(assignable: true)
  int id = 0;
  int index;
  String type;
  int entityId; // since we can't have generics, we have to have separate tables.

  ToOne<Sequence> sequence = ToOne<Sequence>();

  SequenceItem({
    this.id = 0,
    required this.index,
    required this.type,
    required this.entityId,
    required this.sequence,
      });
}
