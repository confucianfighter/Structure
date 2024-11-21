// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_prompt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WritingPromptAdapter extends TypeAdapter<WritingPrompt> {
  @override
  final int typeId = 2;

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
    );
  }

  @override
  void write(BinaryWriter writer, WritingPrompt obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prompt)
      ..writeByte(2)
      ..write(obj.dateCreated)
      ..writeByte(3)
      ..write(obj.lastTimeAnswered);
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

class PromptAnswerAdapter extends TypeAdapter<PromptAnswer> {
  @override
  final int typeId = 3;

  @override
  PromptAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromptAnswer(
      id: fields[0] as String,
      answer: fields[1] as String,
      dateAnswered: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PromptAnswer obj) {
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
      other is PromptAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}