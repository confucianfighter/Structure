import 'package:flutter/material.dart';
import '../../data_store.dart';

class SequencePreviewCard extends StatelessWidget {
  final SequenceItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SequencePreviewCard({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${item.type} - ${item.tableName}'),
        subtitle: Text('Index: ${item.index}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
