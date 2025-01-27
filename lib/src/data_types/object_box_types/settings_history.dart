/// Entity class for storing settings
///
library;

import 'package:Structure/src/data_store.dart';
import 'package:Structure/gen/assets.gen.dart';
import 'package:Structure/src/utils/v1_chat_completions.dart';

@Entity()
class Settings {
  int id = 0; // Automatically managed by ObjectBox
  String homeFolderPath;
  double openai_tts_gain = 2;
  int dateModifiedMillis;
  String? cssStylePath;
  String? codeStylePath;
  String themeMode;
  String? preferredChatCompletionAPI;
  String? preferredGradingAPI;
  String? preferredFlashcardGenerationAPI;

  Settings({
    required this.homeFolderPath,
    required this.dateModifiedMillis,
    required this.themeMode, // Move the default value to the constructor.
  });
  static Settings? get() {
    Settings? settings = Data()
        .store
        .box<Settings>()
        .query()
        .order(Settings_.dateModifiedMillis, flags: Order.descending)
        .build()
        .findFirst();
    settings?.codeStylePath ??= Assets.css.highlight.agate;
    settings?.cssStylePath ??= Assets.css.bootstrap.bootstrapSlateMin;
    return settings;
  }

  static set(Settings value) {
    value.dateModifiedMillis = DateTime.now().microsecondsSinceEpoch;
    Data().store.box<Settings>().put(value);
  }

  static ChatCompletionAPI? convertChatCompletionStringToEnum(String api) {
    // get names of all enum variants
    List<String> enumNames =
        ChatCompletionAPI.values.map((e) => e.name).toList();
    // find the enum variant that matches the string
    for (int i = 0; i< enumNames.length; i++) {
      if( api == enumNames[i]) return ChatCompletionAPI.values[i];
      
    }
    return null;
  }

  static void setPreferredChatCompletionAPI(ChatCompletionAPI api) {
    Settings? settings = get();
    settings?.preferredChatCompletionAPI = api.name;
    set(settings!);
  }

  static void setPreferredGradingAPI(ChatCompletionAPI api) {
    Settings? settings = get();
    settings?.preferredGradingAPI = api.name;
    set(settings!);
  }

  static void setPreferredFlashcardGenerationAPI(ChatCompletionAPI api) {
    Settings? settings = get();
    settings?.preferredFlashcardGenerationAPI = api.name;
    set(settings!);
  }

  static ChatCompletionAPI? getPreferredChatCompletionAPI() {
    Settings? settings = get();
    return convertChatCompletionStringToEnum(
        settings?.preferredChatCompletionAPI ??
            ChatCompletionAPI.OpenAI.name);
  }
  static ChatCompletionAPI? getPreferredFlashcardGenerationAPI() {
    Settings? settings = get();
    return convertChatCompletionStringToEnum(
        settings?.preferredFlashcardGenerationAPI ??
            ChatCompletionAPI.OpenAI.name);
  }
  static ChatCompletionAPI? getPreferredGradingAPI() {
    Settings? settings = get();
    return convertChatCompletionStringToEnum(
        settings?.preferredGradingAPI ??
            ChatCompletionAPI.OpenAI.name);
  }
}
