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
    (sequenceType) => sequenceType.name == name,
   // Optional: returns null if no match is found
  );
}