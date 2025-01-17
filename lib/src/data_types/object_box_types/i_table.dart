import '../../data_store.dart';

abstract class ITable<T> {
  Future<void> save() async{
    await Data().store.box<T>().put(this as T);
  }
}
