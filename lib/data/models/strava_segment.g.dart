// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strava_segment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StravaSegmentAdapter extends TypeAdapter<StravaSegment> {
  @override
  final int typeId = 1;

  @override
  StravaSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StravaSegment(
      id: fields[0] as String,
      name: fields[1] as String,
      activityType: fields[2] as String?,
      distanceMeters: fields[3] as double,
      elevationGainMeters: fields[4] as double,
      avgGrade: fields[5] as double?,
      maxGrade: fields[6] as double?,
      startLatitude: fields[7] as double?,
      startLongitude: fields[8] as double?,
      endLatitude: fields[9] as double?,
      endLongitude: fields[10] as double?,
      personalRecordSeconds: fields[11] as int?,
      isPR: fields[12] as bool? ?? false,
      matchScore: fields[13] as double?,
      rank: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, StravaSegment obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.activityType)
      ..writeByte(3)
      ..write(obj.distanceMeters)
      ..writeByte(4)
      ..write(obj.elevationGainMeters)
      ..writeByte(5)
      ..write(obj.avgGrade)
      ..writeByte(6)
      ..write(obj.maxGrade)
      ..writeByte(7)
      ..write(obj.startLatitude)
      ..writeByte(8)
      ..write(obj.startLongitude)
      ..writeByte(9)
      ..write(obj.endLatitude)
      ..writeByte(10)
      ..write(obj.endLongitude)
      ..writeByte(11)
      ..write(obj.personalRecordSeconds)
      ..writeByte(12)
      ..write(obj.isPR)
      ..writeByte(13)
      ..write(obj.matchScore)
      ..writeByte(14)
      ..write(obj.rank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StravaSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
