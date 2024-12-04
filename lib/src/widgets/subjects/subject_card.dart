import 'package:flutter/material.dart';
import '../../data_store.dart';
import '../flash_cards/flash_card_list_widget.dart'; // Adjust the import path as necessary

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(subject.name),
          subtitle: Text(subject.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            ],
          ),
          onTap: () {
            // Navigate to FlashCardListWidget and pass the subject.id
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashCardListWidget(subject: subject),
              ),
            );
          },
        ),
      ),
    );
  }
}
