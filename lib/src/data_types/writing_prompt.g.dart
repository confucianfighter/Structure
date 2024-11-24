// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_prompt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WritingPromptAdapter extends TypeAdapter<WritingPrompt> {
  @override
  final int typeId = 4;

  @override
  WritingPrompt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingPrompt(
      id: fields[0] as String,
      prompt: fields[1] as String,
      dateCreated: fields[2] as DateTime,
      lastTimeAnswered: fields[3] as DateTime?,
      category: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WritingPrompt obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prompt)
      ..writeByte(2)
      ..write(obj.dateCreated)
      ..writeByte(3)
      ..write(obj.lastTimeAnswered)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingPromptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingPromptAnswerAdapter extends TypeAdapter<WritingPromptAnswer> {
  @override
  final int typeId = 3;

  @override
  WritingPromptAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingPromptAnswer(
      id: fields[0] as String,
      answer: fields[1] as String,
      dateAnswered: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WritingPromptAnswer obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.dateAnswered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingPromptAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
