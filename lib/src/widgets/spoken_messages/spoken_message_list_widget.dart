// Import necessary packages
import 'package:flutter/material.dart';
import '../../data_store.dart'; // Adjust the import path as necessary
import 'spoken_message_card.dart';

// This is the generated file by ObjectBox
class SpokenMessageListWidget extends StatelessWidget {
  const SpokenMessageListWidget({super.key, required this.category});
  static const route = '/spoken_messages';
  final SpokenMessageCategory? category;

  @override
  Widget build(BuildContext context) {
    // Build the query based on the category
    var queryBuilder = Data().store.box<SpokenMessage>().query();
    if (category != null) {
      queryBuilder = Data()
          .store
          .box<SpokenMessage>()
          .query(SpokenMessage_.category.equals(category?.id as int));
    }

    final stream = queryBuilder.watch(triggerImmediately: true);

    return Scaffold(
      appBar: AppBar(
          title: Text('Writing Prompts\nCategory: ${category?.name}'),
          actions: [
            IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  final promptList = Data()
                      .store
                      .box<SpokenMessage>()
                      .query(
                          SpokenMessage_.category.equals(category?.id as int))
                      .build()
                      .find();
                })
          ]),
      body: StreamBuilder<List<SpokenMessage>>(
        stream: stream.map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<SpokenMessage> messages = snapshot.data!;
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return SpokenMessageCard(
                  message: message,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading prompts'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add a new blank writing prompt
          final newPrompt = SpokenMessage(
            text: "",
            lastEdited: DateTime.now(),
          );
          newPrompt.category.target = category;
          Data().store.box<SpokenMessage>().put(newPrompt);
        },
        tooltip: 'Add Prompt',
        child: const Icon(Icons.add),
      ),
    );
  }
}
