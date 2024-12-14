import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart'; // Import your ObjectBox model
import 'flash_card_sequence_widget.dart';

class SequenceItemWidget extends StatelessWidget {
  final SequenceItem sequenceItem;

  const SequenceItemWidget({super.key, required this.sequenceItem});

  @override
  Widget build(BuildContext context) {
    return getWidgetForSequenceType(sequenceItem);
  }
}


Widget getWidgetForSequenceType(SequenceItem sequenceItem) {
  switch (sequenceTypeFromString(sequenceItem.type)) {
    case SequenceType.flashCard:
      return FlashCardSequenceItemWidget(sequenceItemId: sequenceItem.entityId);
    case SequenceType.writingPrompt:
      throw Exception('WritingPromptSequenceWidget not implemented');
    // Add cases for other SequenceTypes
    default:
      throw Exception('Unsupported SequenceType');
  }
}

int newWidgetForSequenceType(SequenceItem sequenceItem) {
  switch (sequenceTypeFromString(sequenceItem.type)) {
    case SequenceType.flashCard:
      final sequence = FlashCardSequence(id: 0, subject: ToOne<Subject>());
      sequence.subject.target = Data().store.box<Subject>().getAll().firstWhere((subject) => subject.name == 'All');
      return Data().store.box<FlashCardSequence>().put(sequence);
    case SequenceType.writingPrompt:
      throw Exception('WritingPromptSequenceWidget not implemented');
    // Add cases for other SequenceTypes
    default:
      throw Exception('Unsupported SequenceType');
  }
}
