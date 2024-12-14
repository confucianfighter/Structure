import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart';
import 'sequence_card.dart';
class SequenceListWidget extends StatelessWidget {
  static const String route = '/sequences';

  const SequenceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sequenceBox = Data().store.box<Sequence>();
    final queryStream = sequenceBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());

    return Scaffold(
      appBar: AppBar(
        title: Text('Sequences'),
      ),
      body: StreamBuilder<List<Sequence>>(
        stream: queryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sequences available.'));
          } else {
            final sequences = snapshot.data!;
            return ListView.builder(
              itemCount: sequences.length,
              itemBuilder: (context, index) {
                final sequence = sequences[index];
                return SequenceCard(
                  sequence: sequence,
                  onEdit: () => _showAddEditDialog(context, sequence: sequence),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Sequence? sequence}) {
    final nameController = TextEditingController(text: sequence?.name ?? '');
    final descriptionController =
        TextEditingController(text: sequence?.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(sequence == null ? 'Add Sequence' : 'Edit Sequence'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final description = descriptionController.text;

                if (name.isNotEmpty && description.isNotEmpty) {
                  final sequenceBox = Data().store.box<Sequence>();
                  if (sequence == null) {
                    // Add new sequence
                    final newSequence =
                        Sequence(name: name, description: description);
                    sequenceBox.put(newSequence);
                  } else {
                    // Update existing sequence
                    sequence.name = name;
                    sequence.description = description;
                    sequenceBox.put(sequence);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
