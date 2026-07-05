// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RideActivityAdapter extends TypeAdapter<RideActivity> {
  @override
  final int typeId = 0;

  @override
  RideActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RideActivity(
      id: fields[0] as String,
      name: fields[1] as String,
      source: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      durationSeconds: fields[5] as int,
      distanceMeters: fields[6] as double,
      elevationGainMeters: fields[7] as double,
      elevationLossMeters: fields[8] as double,
      avgSpeedKmh: fields[9] as double,
      maxSpeedKmh: fields[10] as double,
      avgPowerWatts: fields[11] as double?,
      maxPowerWatts: fields[12] as double?,
      avgHeartRate: fields[13] as int?,
      maxHeartRate: fields[14] as int?,
      avgCadence: fields[15] as int?,
      maxCadence: fields[16] as int?,
      trackPoints: (fields[17] as List).cast<GeoPoint>(),
      matchedSegments: (fields[18] as List?)?.cast<StravaSegment>() ?? [],
      rawDataPath: fields[19] as String?,
      metadata: (fields[20] as Map?)?.cast<String, dynamic>(),
      isUploadedToXingzhe: fields[21] as bool? ?? false,
      description: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RideActivity obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.distanceMeters)
      ..writeByte(7)
      ..write(obj.elevationGainMeters)
      ..writeByte(8)
      ..write(obj.elevationLossMeters)
      ..writeByte(9)
      ..write(obj.avgSpeedKmh)
      ..writeByte(10)
      ..write(obj.maxSpeedKmh)
      ..writeByte(11)
      ..write(obj.avgPowerWatts)
      ..writeByte(12)
      ..write(obj.maxPowerWatts)
      ..writeByte(13)
      ..write(obj.avgHeartRate)
      ..writeByte(14)
      ..write(obj.maxHeartRate)
      ..writeByte(15)
      ..write(obj.avgCadence)
      ..writeByte(16)
      ..write(obj.maxCadence)
      ..writeByte(17)
      ..write(obj.trackPoints)
      ..writeByte(18)
      ..write(obj.matchedSegments)
      ..writeByte(19)
      ..write(obj.rawDataPath)
      ..writeByte(20)
      ..write(obj.metadata)
      ..writeByte(21)
      ..write(obj.isUploadedToXingzhe)
      ..writeByte(22)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
