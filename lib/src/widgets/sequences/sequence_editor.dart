import 'package:flutter/material.dart';
import '../../data_store.dart';

class SequenceEditor extends StatefulWidget {
  final int sequenceId;

  const SequenceEditor({Key? key, required this.sequenceId})
      : super(key: key);

  @override
  _SequenceEditorState createState() => _SequenceEditorState();
}

class _SequenceEditorState extends State<SequenceEditor> {
  late Sequence sequence;
  late List<SequenceItem> items;

  @override
  void initState() {
    super.initState();
    final sequenceBox = Data().store.box<Sequence>();
    sequence = sequenceBox.get(widget.sequenceId)!;
    items = sequence.slots..sort((a, b) => a.index.compareTo(b.index));
  }

  void _updateItemOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      // Update indices and persist changes
      for (int i = 0; i < items.length; i++) {
        items[i].index = i;
        Data().store.box<SequenceItem>().put(items[i]);
      }
    });
  }

  void _addItem() {
    setState(() {
      final newItem = SequenceItem(
        id: 0,
        index: items.length,
        type: 'New Type',
        tableName: 'New Table',
        entityId: 0,
        sequence: ToOne<Sequence>(),
      );
      final id = Data().store.box<SequenceItem>().put(newItem);
      newItem.id = id;
      sequence.slots.add(newItem);
    });
  }

  void _editItem(SequenceItem item) {
    // Implement your edit functionality here
  }

  void _removeItem(SequenceItem item) {
    setState(() {
      items.remove(item);
      Data().store.box<SequenceItem>().remove(item.id);
      sequence.slots.remove(item);
      Data().store.box<Sequence>().put(sequence);
      // Update indices
      for (int i = 0; i < items.length; i++) {
        items[i].index = i;
        Data().store.box<SequenceItem>().put(items[i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Sequence: ${sequence.name}'),
      ),
      body: ReorderableListView(
        onReorder: _updateItemOrder,
        children: [
          for (final item in items)
            ListTile(
              key: ValueKey(item.id),
              title: Text('${item.type} - ${item.tableName}'),
              subtitle: Text('Index: ${item.index}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editItem(item),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeItem(item),
                  ),
                  Icon(Icons.drag_handle),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
