// enum with strings for the sequence types
//
enum SequenceType {
  flashCard,
  writingPrompt,
  session,
  break_time,
}

SequenceType? sequenceTypeFromString(String name) {
  return SequenceType.values.firstWhere(
    (sequence_type) => sequence_type.name == name,
   // Optional: returns null if no match is found
  );
}