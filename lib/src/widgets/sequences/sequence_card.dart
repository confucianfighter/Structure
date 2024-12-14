import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'sequence_editor.dart';

class SequenceCard extends StatelessWidget {
  final Sequence sequence;
  final VoidCallback onEdit;
  const SequenceCard({super.key, required this.sequence, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sequence.name),
      subtitle: Text(sequence.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // Handle play action
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ],
      ),
      onTap: () {
        // launch the sequence editor passing in the sequence
        Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SequenceEditor(sequenceId: sequence.id),
              ),
            );
      },
    );
  }
}
