export 'package:objectbox/objectbox.dart';
export 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';
import '../objectbox.g.dart'; // Adjust this import as needed for your project structure.
import 'data_types/object_box_types/writing_prompt.dart';
import 'data_types/object_box_types/category.dart';
export '../objectbox.g.dart';
export 'data_types/object_box_types/category.dart';
export 'data_types/object_box_types/writing_prompt.dart';
export 'data_types/object_box_types/writing_prompt_answer.dart';
export 'data_types/object_box_types/countdown.dart';
export 'data_types/object_box_types/sequence_item.dart';
// singleton class to manage the ObjectBox store
class Data {
  static final Data _data = Data._internal();
  Store? _store;
  factory Data() {
    return _data;
  }
  Data._internal();
  
  Store get store {
    if (_store == null) {
      _store = Store(getObjectBoxModel());
      _init_tables();
    }
    return _store!;
  }
  Future<void> _init_tables () async {
    // Data().store.box<WritingPrompt>().removeAll();
    // Data().store.box<Category>().removeAll();
    
    await prepopulateWritingPrompts();
  }
  
}