/// Entity class for storing settings
///
import 'package:objectbox/objectbox.dart';
@Entity()
class Settings {
  int id = 0; // Automatically managed by ObjectBox
  String homeFolderPath;

  int dateModifiedMillis;

  String themeMode;

  Settings({
    required this.homeFolderPath,
    required this.dateModifiedMillis,
    required this.themeMode, // Move the default value to the constructor.
  });
}
