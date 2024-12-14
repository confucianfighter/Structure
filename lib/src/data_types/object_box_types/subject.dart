import '../../data_store.dart';

@Entity()
class Subject {
  @Id()
  int id;
  @Unique()
  String name;
  String description;
  String color = '#FFFFFF';
  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
  void Delete(){
    if (name != 'Orphaned' && name != 'All') {
      Data().store.box<Subject>().remove(id);
    }
  }
  static void Init(){
    // check if the 'All' subject exists
    final allSubject = Data().store.box<Subject>().query(Subject_.name.equals( 'All')).build().findFirst();
    if (allSubject == null) {
      final all = Subject(id: 0, name: 'All', description: 'All subjects', color: '#FFFFFF');
      Data().store.box<Subject>().put(all);
    }
    // check if the 'Orphaned' subject exists
    final orphanedSubject = Data().store.box<Subject>().query(Subject_.name.equals( 'Orphaned')).build().findFirst();
    if (orphanedSubject == null) {
      final orphaned = Subject(id: 0, name: 'Orphaned', description: 'Orphaned subjects', color: '#FFFFFF');
      Data().store.box<Subject>().put(orphaned);
    }
  }
}