import 'package:flutter/material.dart';
import '../data_types/object_box_types/countdown.dart';
import '../../objectbox.g.dart';
import 'dart:async';
import '../data_store.dart';

class ObjectBoxCountdownWidget extends StatefulWidget {
  final int countdownId;
  const ObjectBoxCountdownWidget({super.key, required this.countdownId});

  @override
  _ObjectBoxCountdownWidgetState createState() =>
      _ObjectBoxCountdownWidgetState();
}

class _ObjectBoxCountdownWidgetState extends State<ObjectBoxCountdownWidget> {
  late final Stream<Countdown?> _countDownStream;

  @override
  void initState() {
    
    // Initialize the query for the countdown
    _countDownStream = Data()
        .store
        .box<Countdown>()
        .query(Countdown_.id.equals(widget.countdownId))
        .watch()
        .map((query) => query.findFirst() as Countdown);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Countdown?>(
        stream: _countDownStream,
        // Find the first result from the query
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.) {
          //   // Show a loading spinner while waiting
          //   return Center(child: CircularProgressIndicator());
          // } else if (snapshot.hasError) {
          //   // Display the error if there is one
          //   return Center(child: Text('Error: ${snapshot.error}'));
          // } else if (!snapshot.hasData || snapshot.data == null) {
          //   // Inform the user if no countdown is available
          //   return Center(child: Text('No countdown available'));
          // } else {
          // Display the remaining time
          int? remainingSeconds;
          if (snapshot.hasData) {
            remainingSeconds = snapshot.data!.remainingSeconds;
          }
          String message = remainingSeconds == null
              ? 'No timer active'
              : 'Remaining Time: ${remainingSeconds} seconds';
          return Center(
            child: Text(
              message,
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        // },
        );
  }

  @override
  void dispose() {
    // Close the query to release resources

    super.dispose();
  }
}
