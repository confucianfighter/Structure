import 'package:flutter/services.dart';
import 'package:toml/toml.dart';
import '../../data_store.dart';

@Entity()
class SpokenMessage {
  @Id()
  int id = 0;

  @Unique()
  String? text;

  @Unique()
  String? audioFilePath;

  @Property(type: PropertyType.date)
  DateTime? lastEdited;

  @Property(type: PropertyType.date)
  DateTime? lastTimeUsed;

  ToOne<SpokenMessageCategory> category = ToOne<SpokenMessageCategory>();

  SpokenMessage({
    required this.text,
    required this.lastEdited,
    this.lastTimeUsed,
    this.id = 0,
  });
}
