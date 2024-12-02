import 'package:objectbox/objectbox.dart';

@Entity()
class Sequence {
  int id;
  String name;

  @Backlink()
  final slots = ToMany<SequenceItem>();

  Sequence({this.id = 0, required this.name});
}

@Entity()
class SequenceItem {
  @Id(assignable: true)
  int id = 0;
  int index;
  String type;
  String
      tableName; //type and table name may or may not be identical. What if we want two types of things with the same data?
  int entityId; // since we can't have generics, we have to have separate tables.

  ToOne<Sequence> sequence = ToOne<Sequence>();

  SequenceItem({
    this.id = 0,
    required this.index,
    required this.type,
    required this.tableName,
    required this.entityId,
    required this.sequence,
  });
}
