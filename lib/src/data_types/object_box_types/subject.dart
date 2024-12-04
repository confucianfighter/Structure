import '../../data_store.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Subject {
  @Id()
  int id;
  @Unique()
  String name;
  String description;
  String color = '#FFFFFF';
  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}