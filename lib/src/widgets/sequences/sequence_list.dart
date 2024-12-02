import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'sequence_editor.dart';

class SequenceListWidget extends StatelessWidget {
  const SequenceListWidget({Key? key}) : super(key: key);
  static const route = '/sequences';
  @override
  Widget build(BuildContext context) {
    // Query all sequences
    final sequenceBox = Data().store.box<Sequence>();
    final sequences = sequenceBox.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sequences'),
      ),
      body: ListView.builder(
        itemCount: sequences.length,
        itemBuilder: (context, index) {
          final sequence = sequences[index];
          return ListTile(
            title: Text(sequence.name),
            onTap: () {
              // Navigate to the Sequence Editor Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SequenceEditor(sequenceId: sequence.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding a new sequence
          final newSequence = Sequence(name: 'New Sequence');
          sequenceBox.put(newSequence);
          // Refresh the list
          (context as Element).reassemble();
        },
        tooltip: 'Add Sequence',
        child: const Icon(Icons.add),
      ),
    );
  }
}
