import 'assets_map.dart';

class Assets {
  // create a singleton class
  Assets._internal();
  static final Assets _singleton = Assets._internal();
  
  factory Assets() {
    return _singleton;
  }

  List<String> getFileNames(String path) {
    return assets['assets/$path']!;
  }

  List<String> getFilePaths(String path) {
    return getFileNames(path).map((fileName) => 'assets/$path/$fileName').toList();
  }
}
