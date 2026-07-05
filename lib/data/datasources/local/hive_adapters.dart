import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models/ride_activity.dart';
import '../../../data/models/strava_segment.dart';
import '../../../data/models/geo_point.dart';

Future<void> registerHiveAdapters() async {
  // Register adapters for models
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(RideActivityAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(StravaSegmentAdapter());
  }
  
  // Open boxes
  await Hive.openBox<RideActivity>('activities');
  await Hive.openBox('settings');
  await Hive.openBox('strava_tokens');
}
