import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'strava_segment.g.dart';

/// Represents a Strava segment
@HiveType(typeId: 1)
class StravaSegment extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? activityType;
  
  @HiveField(3)
  final double distanceMeters;
  
  @HiveField(4)
  final double elevationGainMeters;
  
  @HiveField(5)
  final double? avgGrade;
  
  @HiveField(6)
  final double? maxGrade;
  
  @HiveField(7)
  final double? startLatitude;
  
  @HiveField(8)
  final double? startLongitude;
  
  @HiveField(9)
  final double? endLatitude;
  
  @HiveField(10)
  final double? endLongitude;
  
  @HiveField(11)
  final int? personalRecordSeconds;
  
  @HiveField(12)
  final bool isPR;
  
  @HiveField(13)
  final double? matchScore;
  
  @HiveField(14)
  final int? rank;

  const StravaSegment({
    required this.id,
    required this.name,
    this.activityType,
    required this.distanceMeters,
    required this.elevationGainMeters,
    this.avgGrade,
    this.maxGrade,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.personalRecordSeconds,
    this.isPR = false,
    this.matchScore,
    this.rank,
  });

  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000;
  
  /// Personal record as Duration
  Duration? get personalRecord => 
    personalRecordSeconds != null 
      ? Duration(seconds: personalRecordSeconds!) 
      : null;

  /// Create from Strava API response
  factory StravaSegment.fromStravaJson(Map<String, dynamic> json) {
    final prTime = json['pr_time'];
    final elapsedTime = json['elapsed_time'];
    
    return StravaSegment(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Segment',
      activityType: json['activity_type'] as String?,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      elevationGainMeters: (json['total_elevation_gain'] as num?)?.toDouble() ?? 0,
      avgGrade: (json['average_grade'] as num?)?.toDouble(),
      maxGrade: (json['maximum_grade'] as num?)?.toDouble(),
      startLatitude: (json['start_latlng'] as List?)?.firstOrNull?.toDouble(),
      startLongitude: (json['start_latlng'] as List?)?.lastOrNull?.toDouble(),
      endLatitude: (json['end_latlng'] as List?)?.firstOrNull?.toDouble(),
      endLongitude: (json['end_latlng'] as List?)?.lastOrNull?.toDouble(),
      personalRecordSeconds: prTime as int? ?? elapsedTime as int?,
      isPR: json['pr_rank'] == 1,
      rank: json['rank'] as int?,
    );
  }

  /// Create from Strava segment explore response
  factory StravaSegment.fromExploreJson(Map<String, dynamic> json) {
    return StravaSegment(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown',
      activityType: json['activity_type'] as String?,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      elevationGainMeters: (json['elev_difference'] as num?)?.toDouble() ?? 0,
      avgGrade: (json['avg_grade'] as num?)?.toDouble(),
      maxGrade: (json['max_grade'] as num?)?.toDouble(),
      startLatitude: (json['start_latlng'] as List?)?.firstOrNull?.toDouble(),
      startLongitude: (json['start_latlng'] as List?)?.lastOrNull?.toDouble(),
      endLatitude: (json['end_latlng'] as List?)?.firstOrNull?.toDouble(),
      endLongitude: (json['end_latlng'] as List?)?.lastOrNull?.toDouble(),
    );
  }

  StravaSegment copyWith({
    String? id,
    String? name,
    String? activityType,
    double? distanceMeters,
    double? elevationGainMeters,
    double? avgGrade,
    double? maxGrade,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
    int? personalRecordSeconds,
    bool? isPR,
    double? matchScore,
    int? rank,
  }) {
    return StravaSegment(
      id: id ?? this.id,
      name: name ?? this.name,
      activityType: activityType ?? this.activityType,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      avgGrade: avgGrade ?? this.avgGrade,
      maxGrade: maxGrade ?? this.maxGrade,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      personalRecordSeconds: personalRecordSeconds ?? this.personalRecordSeconds,
      isPR: isPR ?? this.isPR,
      matchScore: matchScore ?? this.matchScore,
      rank: rank ?? this.rank,
    );
  }

  @override
  List<Object?> get props => [
    id, name, activityType, distanceMeters, elevationGainMeters,
    avgGrade, maxGrade, startLatitude, startLongitude,
    endLatitude, endLongitude, personalRecordSeconds, isPR, rank,
  ];
}
