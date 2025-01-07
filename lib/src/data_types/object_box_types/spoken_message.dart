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

  double speed = .75;
  double gain = 2;
  String voice = "nova";
  ToOne<SpokenMessageCategory> category = ToOne<SpokenMessageCategory>();

  SpokenMessage({
    required this.text,
    required this.lastEdited,
    required this.speed,
    required this.voice,
    required this.gain,
    this.lastTimeUsed,
    this.id = 0,
  });
}
