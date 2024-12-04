import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart';
import 'sequence_item_widget.dart';
import '../../data_store.dart';
import 'sequence_card.dart';

class SequenceEditor extends StatelessWidget {
  final int sequenceId; // Added to identify the specific sequence

  const SequenceEditor({
    Key? key,
    required this.sequenceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sequenceItemBox = Data().store.box<SequenceItem>();
    final queryStream = sequenceItemBox
        .query(SequenceItem_.sequence.equals(sequenceId))
        .order(SequenceItem_.index) // Sort by index in ascending order
        .watch(triggerImmediately: true)
        .map((query) => query.find());

    return Scaffold(
      appBar: AppBar(
        title: Text('Sequence Editor'),
      ),
      body: StreamBuilder<List<SequenceItem>>(
        stream: queryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sequence items available.'));
          } else {
            final sequenceItems = snapshot.data!;
            return ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = sequenceItems.removeAt(oldIndex);
                sequenceItems.insert(newIndex, item);
                // Update indices in the database
                for (int i = 0; i < sequenceItems.length; i++) {
                  sequenceItems[i].index = i;
                  Data().store.box<SequenceItem>().put(sequenceItems[i]);
                }
              },
              children: sequenceItems.map((item) {
                return SequenceItemWidget(
                  key: ValueKey(item.id),
                  sequenceItemId: item.id,
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, sequenceItemBox),
        child: Icon(Icons.add),
      ),
    );
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
                    index: sequenceItemBox
                        .query(SequenceItem_.sequence.equals(sequenceId))
                        .build()
                        .count(),
                    type: selectedType!.name,
                    entityId: 0, // Replace with actual entityId
                    sequence: ToOne<Sequence>()..targetId = sequenceId,
                  );
                  sequenceItemBox.put(newItem);
                  newWidgetForSequenceType(newItem);
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
