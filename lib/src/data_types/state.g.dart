// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStateAdapter extends TypeAdapter<AppState> {
  @override
  final int typeId = 5;

  @override
  AppState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppState()
      ..timeRemainingSeconds = fields[0] as int?
      ..mode = fields[1] as Mode?;
  }

  @override
  void write(BinaryWriter writer, AppState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timeRemainingSeconds)
      ..writeByte(1)
      ..write(obj.mode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
