import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'geo_point.dart';
import 'strava_segment.dart';

part 'ride_activity.g.dart';

/// Data source of the activity
enum ActivitySource {
  wanlu,      // 顽鹿运动
  igpsport,   // iGPSSport
  fitFile,    // FIT文件导入
  manual,     // 手动创建
}

/// Main model representing a cycling activity
@HiveType(typeId: 0)
class RideActivity extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String source;
  
  @HiveField(3)
  final DateTime startTime;
  
  @HiveField(4)
  final DateTime endTime;
  
  @HiveField(5)
  final int durationSeconds;
  
  @HiveField(6)
  final double distanceMeters;
  
  @HiveField(7)
  final double elevationGainMeters;
  
  @HiveField(8)
  final double elevationLossMeters;
  
  @HiveField(9)
  final double avgSpeedKmh;
  
  @HiveField(10)
  final double maxSpeedKmh;
  
  @HiveField(11)
  final double? avgPowerWatts;
  
  @HiveField(12)
  final double? maxPowerWatts;
  
  @HiveField(13)
  final int? avgHeartRate;
  
  @HiveField(14)
  final int? maxHeartRate;
  
  @HiveField(15)
  final int? avgCadence;
  
  @HiveField(16)
  final int? maxCadence;
  
  @HiveField(17)
  final List<GeoPoint> trackPoints;
  
  @HiveField(18)
  final List<StravaSegment> matchedSegments;
  
  @HiveField(19)
  final String? rawDataPath;
  
  @HiveField(20)
  final Map<String, dynamic>? metadata;
  
  @HiveField(21)
  final bool isUploadedToXingzhe;
  
  @HiveField(22)
  final String? description;

  const RideActivity({
    required this.id,
    required this.name,
    required this.source,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.elevationGainMeters,
    required this.elevationLossMeters,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    this.avgPowerWatts,
    this.maxPowerWatts,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgCadence,
    this.maxCadence,
    required this.trackPoints,
    this.matchedSegments = const [],
    this.rawDataPath,
    this.metadata,
    this.isUploadedToXingzhe = false,
    this.description,
  });

  /// Duration as Duration object
  Duration get duration => Duration(seconds: durationSeconds);
  
  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000;
  
  /// Create from FIT file data
  factory RideActivity.fromFitData({
    required String id,
    required List<GeoPoint> trackPoints,
    required DateTime startTime,
    required DateTime endTime,
    String? name,
  }) {
    // Calculate statistics from track points
    double totalDistance = 0;
    double elevationGain = 0;
    double elevationLoss = 0;
    double? prevAltitude;
    double? prevLat;
    double? prevLon;
    
    double maxSpeed = 0;
    double speedSum = 0;
    int speedCount = 0;
    
    double? maxPower;
    double powerSum = 0;
    int powerCount = 0;
    
    int? maxHeartRate;
    int heartRateSum = 0;
    int heartRateCount = 0;
    
    int? maxCadence;
    int cadenceSum = 0;
    int cadenceCount = 0;
    
    for (int i = 1; i < trackPoints.length; i++) {
      final point = trackPoints[i];
      final prevPoint = trackPoints[i - 1];
      
      // Calculate distance using Haversine formula
      final dist = _calculateDistance(
        prevPoint.latitude, prevPoint.longitude,
        point.latitude, point.longitude,
      );
      totalDistance += dist;
      
      // Calculate elevation changes
      if (point.altitudeMeters != null && prevPoint.altitudeMeters != null) {
        final elevDiff = point.altitudeMeters! - prevPoint.altitudeMeters!;
        if (elevDiff > 0) {
          elevationGain += elevDiff;
        } else {
          elevationLoss += elevDiff.abs();
        }
      }
      
      // Track speed
      if (point.speedMps != null) {
        final speedKmh = point.speedKmh;
        if (speedKmh > maxSpeed) maxSpeed = speedKmh;
        speedSum += speedKmh;
        speedCount++;
      }
      
      // Track power
      if (point.power != null) {
        if (maxPower == null || point.power! > maxPower) {
          maxPower = point.power;
        }
        powerSum += point.power!;
        powerCount++;
      }
      
      // Track heart rate
      if (point.heartRate != null) {
        if (maxHeartRate == null || point.heartRate! > maxHeartRate) {
          maxHeartRate = point.heartRate;
        }
        heartRateSum += point.heartRate!;
        heartRateCount++;
      }
      
      // Track cadence
      if (point.cadence != null) {
        if (maxCadence == null || point.cadence! > maxCadence) {
          maxCadence = point.cadence;
        }
        cadenceSum += point.cadence!;
        cadenceCount++;
      }
    }
    
    return RideActivity(
      id: id,
      name: name ?? 'Ride Activity',
      source: ActivitySource.fitFile.name,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: endTime.difference(startTime).inSeconds,
      distanceMeters: totalDistance,
      elevationGainMeters: elevationGain,
      elevationLossMeters: elevationLoss,
      avgSpeedKmh: speedCount > 0 ? speedSum / speedCount : 0,
      maxSpeedKmh: maxSpeed,
      avgPowerWatts: powerCount > 0 ? powerSum / powerCount : null,
      maxPowerWatts: maxPower,
      avgHeartRate: heartRateCount > 0 ? (heartRateSum / heartRateCount).round() : null,
      maxHeartRate: maxHeartRate,
      avgCadence: cadenceCount > 0 ? (cadenceSum / cadenceCount).round() : null,
      maxCadence: maxCadence,
      trackPoints: trackPoints,
      matchedSegments: [],
    );
  }
  
  /// Create from Wanlu API response
  factory RideActivity.fromWanluJson(Map<String, dynamic> json) {
    final trackPoints = (json['track_points'] as List?)
        ?.map((e) => GeoPoint.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    
    return RideActivity(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Wanlu Activity',
      source: ActivitySource.wanlu.name,
      startTime: DateTime.tryParse(json['start_time'] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0,
      elevationGainMeters: (json['elevation_gain'] as num?)?.toDouble() ?? 0,
      elevationLossMeters: (json['elevation_loss'] as num?)?.toDouble() ?? 0,
      avgSpeedKmh: (json['avg_speed_kmh'] as num?)?.toDouble() ?? 0,
      maxSpeedKmh: (json['max_speed_kmh'] as num?)?.toDouble() ?? 0,
      avgPowerWatts: (json['avg_power'] as num?)?.toDouble(),
      maxPowerWatts: (json['max_power'] as num?)?.toDouble(),
      avgHeartRate: json['avg_heart_rate'] as int?,
      maxHeartRate: json['max_heart_rate'] as int?,
      avgCadence: json['avg_cadence'] as int?,
      maxCadence: json['max_cadence'] as int?,
      trackPoints: trackPoints,
      metadata: json,
    );
  }
  
  /// Create from iGPSSport API response
  factory RideActivity.fromIgpsJson(Map<String, dynamic> json) {
    final trackPoints = (json['records'] as List?)
        ?.map((e) => GeoPoint.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    
    return RideActivity(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'iGPS Activity',
      source: ActivitySource.igpsport.name,
      startTime: DateTime.tryParse(json['start_time'] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: json['duration'] as int? ?? 0,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      elevationGainMeters: (json['ascent'] as num?)?.toDouble() ?? 0,
      elevationLossMeters: (json['descent'] as num?)?.toDouble() ?? 0,
      avgSpeedKmh: (json['avg_speed'] as num?)?.toDouble() ?? 0,
      maxSpeedKmh: (json['max_speed'] as num?)?.toDouble() ?? 0,
      avgPowerWatts: (json['avg_power'] as num?)?.toDouble(),
      maxPowerWatts: (json['max_power'] as num?)?.toDouble(),
      avgHeartRate: json['avg_hr'] as int?,
      maxHeartRate: json['max_hr'] as int?,
      avgCadence: json['avg_cad'] as int?,
      maxCadence: json['max_cad'] as int?,
      trackPoints: trackPoints,
      metadata: json,
    );
  }
  
  /// Calculate distance using Haversine formula
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = 
      _sin(dLat / 2) * _sin(dLat / 2) +
      _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
      _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }
  
  static double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  static double _sin(double x) => _sinApprox(x);
  static double _cos(double x) => _cosApprox(x);
  static double _sqrt(double x) => _sqrtApprox(x);
  static double _atan2(double y, double x) => _atan2Approx(y, x);
  
  static double _sinApprox(double x) {
    // Normalize x to [-pi, pi]
    while (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    while (x < -3.141592653589793) x += 2 * 3.141592653589793;
    // Taylor series approximation
    double result = x;
    double term = x;
    for (int i = 1; i <= 7; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
  
  static double _cosApprox(double x) {
    return _sinApprox(x + 3.141592653589793 / 2);
  }
  
  static double _sqrtApprox(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  
  static double _atan2Approx(double y, double x) {
    if (x > 0) return _atanApprox(y / x);
    if (x < 0 && y >= 0) return _atanApprox(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atanApprox(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  
  static double _atanApprox(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
  
  RideActivity copyWith({
    String? id,
    String? name,
    String? source,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    double? distanceMeters,
    double? elevationGainMeters,
    double? elevationLossMeters,
    double? avgSpeedKmh,
    double? maxSpeedKmh,
    double? avgPowerWatts,
    double? maxPowerWatts,
    int? avgHeartRate,
    int? maxHeartRate,
    int? avgCadence,
    int? maxCadence,
    List<GeoPoint>? trackPoints,
    List<StravaSegment>? matchedSegments,
    String? rawDataPath,
    Map<String, dynamic>? metadata,
    bool? isUploadedToXingzhe,
    String? description,
  }) {
    return RideActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      avgPowerWatts: avgPowerWatts ?? this.avgPowerWatts,
      maxPowerWatts: maxPowerWatts ?? this.maxPowerWatts,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      avgCadence: avgCadence ?? this.avgCadence,
      maxCadence: maxCadence ?? this.maxCadence,
      trackPoints: trackPoints ?? this.trackPoints,
      matchedSegments: matchedSegments ?? this.matchedSegments,
      rawDataPath: rawDataPath ?? this.rawDataPath,
      metadata: metadata ?? this.metadata,
      isUploadedToXingzhe: isUploadedToXingzhe ?? this.isUploadedToXingzhe,
      description: description ?? this.description,
    );
  }
  
  @override
  List<Object?> get props => [
    id, name, source, startTime, endTime, durationSeconds,
    distanceMeters, elevationGainMeters, elevationLossMeters,
    avgSpeedKmh, maxSpeedKmh, avgPowerWatts, maxPowerWatts,
    avgHeartRate, maxHeartRate, avgCadence, maxCadence,
    trackPoints, matchedSegments, isUploadedToXingzhe,
  ];
}
