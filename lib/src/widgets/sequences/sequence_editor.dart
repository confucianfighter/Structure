import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'sequence_item_widget.dart';

class SequenceEditor extends StatefulWidget {
  final int sequenceId;

  const SequenceEditor({super.key, required this.sequenceId});

  @override
  _SequenceEditorState createState() => _SequenceEditorState();
}

class _SequenceEditorState extends State<SequenceEditor> {
  List<SequenceItem> sequenceItems = [];
  late Box<SequenceItem> sequenceItemBox;

  @override
  void initState() {
    super.initState();
    sequenceItemBox = Data().store.box<SequenceItem>();
    loadSequenceItems();
  }

  void loadSequenceItems() {
    final query = sequenceItemBox.query(SequenceItem_.sequence.equals(widget.sequenceId))
        .order(SequenceItem_.index);
    setState(() {
      sequenceItems = query.build().find();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sequence Editor'),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {

            if (newIndex > oldIndex) newIndex -= 1;
            final item = sequenceItems.removeAt(oldIndex);
            sequenceItems.insert(newIndex, item);

            // Update indices
            for (int i = 0; i < sequenceItems.length; i++) {
              sequenceItems[i].index = i;
            }
            saveChanges();
            setState(() {});         
        },
        children: sequenceItems.map((item) {
          return SequenceItemWidget(
            key: ValueKey(item.id),
            sequenceItem: item,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context, sequenceItemBox);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void saveChanges() {
    // Batch update all changes to minimize triggering watch events.
    sequenceItemBox.putMany(sequenceItems);
  }

  


  void _showAddItemDialog(
      BuildContext context, Box<SequenceItem> sequenceItemBox) {
    SequenceType? selectedType;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Sequence Item'),
          content: DropdownButtonFormField<SequenceType>(
            decoration: InputDecoration(
              labelText: 'Select Item Type',
            ),
            items: SequenceType.values.map((SequenceType type) {
              return DropdownMenuItem<SequenceType>(
                value: type,
                child: Text(type.toString().split('.').last),
              );
            }).toList(),
            onChanged: (SequenceType? newType) {
              selectedType = newType;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedType != null) {
                  final newItem = SequenceItem(
                    index: sequenceItems.length,
                    type: selectedType!.name,
                    entityId: 0, // Replace with actual entityId
                    sequence: ToOne<Sequence>()..targetId = widget.sequenceId,
                  );
                  newItem.entityId = newWidgetForSequenceType(newItem);
                  sequenceItemBox.put(newItem);
                  setState(() {
                    sequenceItems.add(newItem);
                  });
                                  }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
