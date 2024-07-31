// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayers_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerAdapter extends TypeAdapter<Prayer> {
  @override
  final int typeId = 1;

  @override
  Prayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Prayer(
      fields[0] as String,
      fields[1] as int,
      fields[2] == null ? 0 : fields[2] as int,
      fields[3] as String,
      numberOfCompletedPrayers: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Prayer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.total)
      ..writeByte(2)
      ..write(obj.finished)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.numberOfCompletedPrayers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
