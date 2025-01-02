abstract class IHtml {
  /// Path to the CSS stylesheet
  String get stylePath;
  set stylePath(String path);

  /// Path to additional styles or scripts
  String get codeStylePath;
  set codeStylePath(String path);

  /// HTML content to be displayed or processed
  String get htmlText;
  set htmlText(String text);
}
