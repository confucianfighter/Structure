import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart'; // Import your ObjectBox model
import 'flash_card_sequence_widget.dart';

class SequenceItemWidget extends StatelessWidget {
  final int sequenceItemId;
  const SequenceItemWidget({Key? key, required this.sequenceItemId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sequenceItemBox = Data().store.box<SequenceItem>();
    final query =
        sequenceItemBox.query(SequenceItem_.id.equals(sequenceItemId));
    final queryStream =
        query.watch(triggerImmediately: true).map((q) => q.findFirst());

    return StreamBuilder<SequenceItem?>(
      stream: queryStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('Sequence item not found.');
        } else {
          final sequenceItem = snapshot.data!;
          return getWidgetForSequenceType(sequenceItem);
        }
      },
    );
  }

  void setIndex(int index) {
    SequenceItem? sequenceItem =
        Data().store.box<SequenceItem>().get(sequenceItemId);
    sequenceItem!.index = index;
    Data().store.box<SequenceItem>().put(sequenceItem);
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

void newWidgetForSequenceType(SequenceItem sequenceItem) {
  switch (sequenceTypeFromString(sequenceItem.type)) {
    case SequenceType.flashCard:
      final sequence = FlashCardSequence(id: 0, subject: ToOne<Subject>());
      int id = Data().store.box<FlashCardSequence>().put(sequence);
      sequenceItem.entityId = id;
      Data().store.box<SequenceItem>().put(sequenceItem);
    case SequenceType.writingPrompt:
      throw Exception('WritingPromptSequenceWidget not implemented');
    // Add cases for other SequenceTypes
    default:
      throw Exception('Unsupported SequenceType');
  }
}
