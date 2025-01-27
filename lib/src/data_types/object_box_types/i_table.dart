import '../../data_store.dart';

abstract class ITable<T> {
  Future<void> save() async {
    Data().store.box<T>().put(this as T);
  }

  Future<void> delete() async {
    Data().store.box<T>().remove(getId());
  }

  Future<T?> refresh() async {
    return Data().store.box<T>().get(getId());
  }

  int getId();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ITable<T>) return false;
    return getId() == other.getId();
  }

  @override
  int get hashCode => getId().hashCode;
}
