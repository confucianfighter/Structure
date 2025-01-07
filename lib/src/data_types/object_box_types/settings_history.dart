/// Entity class for storing settings
///
library;
import 'package:Structure/src/data_store.dart';
import 'package:Structure/gen/assets.gen.dart';
@Entity()
class Settings {
  int id = 0; // Automatically managed by ObjectBox
  String homeFolderPath;
  double openai_tts_gain = 2;
  int dateModifiedMillis;
  String? cssStylePath;
  String? codeStylePath;
  String themeMode;

  Settings({
    required this.homeFolderPath,
    required this.dateModifiedMillis,
    required this.themeMode, // Move the default value to the constructor.
  });
  static Settings? get(){
    Settings? settings = Data()
        .store
        .box<Settings>()
        .query()
        .order(Settings_.dateModifiedMillis,
            flags: Order.descending)
        .build()
        .findFirst();
    settings?.codeStylePath ??= Assets.css.highlight.agate;
    settings?.cssStylePath ??= Assets.css.bootstrap.bootstrapSlateMin;
    return settings;
  }
  
  static set(Settings value){
    value.dateModifiedMillis = DateTime.now().microsecondsSinceEpoch;
    Data().store.box<Settings>().put(value);
  }
}
