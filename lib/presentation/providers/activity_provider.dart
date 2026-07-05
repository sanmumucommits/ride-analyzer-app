import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/ride_activity.dart';
import '../../data/models/geo_point.dart';

// Activities Box Provider
final activitiesBoxProvider = Provider<Box<RideActivity>>((ref) {
  return Hive.box<RideActivity>('activities');
});

// Activity List Provider
final activityListProvider = StateNotifierProvider<ActivityListNotifier, AsyncValue<List<RideActivity>>>((ref) {
  final box = ref.watch(activitiesBoxProvider);
  return ActivityListNotifier(box);
});

class ActivityListNotifier extends StateNotifier<AsyncValue<List<RideActivity>>> {
  final Box<RideActivity> _box;

  ActivityListNotifier(this._box) : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncValue.loading();
    try {
      final activities = _box.values.toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addActivity(RideActivity activity) async {
    await _box.put(activity.id, activity);
    await loadActivities();
  }

  Future<void> updateActivity(RideActivity activity) async {
    await _box.put(activity.id, activity);
    await loadActivities();
  }

  Future<void> deleteActivity(String id) async {
    await _box.delete(id);
    await loadActivities();
  }

  Future<void> importFromFit(String filePath) async {
    // Parse FIT file and create activity
    // This is a placeholder - actual implementation would use fit_file_parser
    final uuid = const Uuid();
    final now = DateTime.now();
    
    // Mock data for demonstration
    final mockTrackPoints = _generateMockTrackPoints();
    
    final activity = RideActivity.fromFitData(
      id: uuid.v4(),
      trackPoints: mockTrackPoints,
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now,
      name: 'Imported Ride',
    );
    
    await addActivity(activity);
  }

  List<GeoPoint> _generateMockTrackPoints() {
    // Generate mock track points for demonstration
    final points = <GeoPoint>[];
    final baseLat = 31.2304;  // Shanghai
    final baseLon = 121.4737;
    
    for (int i = 0; i < 100; i++) {
      points.add(GeoPoint(
        latitude: baseLat + (i * 0.001),
        longitude: baseLon + (i * 0.0005),
        altitudeMeters: 10 + (i * 0.5),
        speedMps: 8 + (i % 10) * 0.5,
        heartRate: 120 + (i % 40),
        cadence: 80 + (i % 20),
        power: 150 + (i % 100) * 2,
        timestamp: DateTime.now().subtract(Duration(minutes: 100 - i)),
      ));
    }
    
    return points;
  }
}

// Activity Summary Provider
final activitySummaryProvider = Provider<ActivitySummary>((ref) {
  final activitiesAsync = ref.watch(activityListProvider);
  
  return activitiesAsync.when(
    data: (activities) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
      
      final weekActivities = activities.where(
        (a) => a.startTime.isAfter(startOfWeek),
      ).toList();
      
      return ActivitySummary(
        totalRides: weekActivities.length,
        totalDistance: weekActivities.fold(0.0, (sum, a) => sum + a.distanceMeters),
        totalDuration: weekActivities.fold(
          Duration.zero,
          (sum, a) => sum + a.duration,
        ),
        totalElevation: weekActivities.fold(0.0, (sum, a) => sum + a.elevationGainMeters),
      );
    },
    loading: () => const ActivitySummary(),
    error: (_, __) => const ActivitySummary(),
  );
});

class ActivitySummary {
  final int totalRides;
  final double totalDistance;
  final Duration totalDuration;
  final double totalElevation;

  const ActivitySummary({
    this.totalRides = 0,
    this.totalDistance = 0,
    this.totalDuration = Duration.zero,
    this.totalElevation = 0,
  });
}

// Selected Activity Provider
final selectedActivityProvider = StateProvider<RideActivity?>((ref) => null);

// Activity Detail Provider
final activityDetailProvider = FutureProvider.family<RideActivity?, String>((ref, id) async {
  final box = ref.watch(activitiesBoxProvider);
  return box.get(id);
});
