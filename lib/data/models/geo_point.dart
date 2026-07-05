import 'package:equatable/equatable.dart';

/// Represents a single GPS track point with optional sensor data
class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;
  final double? altitudeMeters;
  final double? speedMps;
  final int? heartRate;
  final int? cadence;
  final double? power;
  final DateTime timestamp;
  final double? temperature;
  final double? grade;
  
  const GeoPoint({
    required this.latitude,
    required this.longitude,
    this.altitudeMeters,
    this.speedMps,
    this.heartRate,
    this.cadence,
    this.power,
    required this.timestamp,
    this.temperature,
    this.grade,
  });
  
  /// Speed in km/h
  double get speedKmh => (speedMps ?? 0) * 3.6;
  
  /// Create from FIT file record
  factory GeoPoint.fromFitRecord(Map<String, dynamic> record) {
    return GeoPoint(
      latitude: record['position_lat'] ?? 0.0,
      longitude: record['position_long'] ?? 0.0,
      altitudeMeters: record['altitude']?.toDouble(),
      speedMps: record['speed']?.toDouble(),
      heartRate: record['heart_rate'],
      cadence: record['cadence'],
      power: record['power']?.toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (record['timestamp'] ?? 0) * 1000,
      ),
    );
  }
  
  /// Create from JSON
  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitudeMeters: json['altitude_meters']?.toDouble(),
      speedMps: json['speed_mps']?.toDouble(),
      heartRate: json['heart_rate'] as int?,
      cadence: json['cadence'] as int?,
      power: json['power']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      temperature: json['temperature']?.toDouble(),
      grade: json['grade']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude_meters': altitudeMeters,
      'speed_mps': speedMps,
      'heart_rate': heartRate,
      'cadence': cadence,
      'power': power,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'grade': grade,
    };
  }
  
  @override
  List<Object?> get props => [
    latitude, longitude, altitudeMeters, speedMps,
    heartRate, cadence, power, timestamp,
  ];
}
