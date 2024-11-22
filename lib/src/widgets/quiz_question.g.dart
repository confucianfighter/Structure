// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizQuestionAdapter extends TypeAdapter<QuizQuestion> {
  @override
  final int typeId = 0;

  @override
  QuizQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestion(
      question: fields[0] as String,
      answer: fields[1] as String,
      id: fields[2] as String,
      timesAnsweredCorrectly: fields[3] as int,
      mostRecentCorrectAnswer: fields[4] as DateTime?,
      tags: (fields[5] as List).cast<String>(),
      subjects: (fields[6] as List).cast<String>(),
      questionImage: fields[7] as String?,
      answerImage: fields[8] as String?,
      link: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestion obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.timesAnsweredCorrectly)
      ..writeByte(4)
      ..write(obj.mostRecentCorrectAnswer)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.subjects)
      ..writeByte(7)
      ..write(obj.questionImage)
      ..writeByte(8)
      ..write(obj.answerImage)
      ..writeByte(9)
      ..write(obj.link);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
