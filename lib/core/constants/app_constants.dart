class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'RidePower';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String activitiesBox = 'activities_box';
  static const String settingsBox = 'settings_box';
  static const String stravaTokenKey = 'strava_access_token';
  static const String stravaRefreshKey = 'strava_refresh_token';
  static const String lastSyncKey = 'last_sync_time';
  
  // API Endpoints
  static const String stravaBaseUrl = 'https://www.strava.com/api/v3';
  static const String wanluBaseUrl = 'https://api.wanlu.com';
  static const String igpsBaseUrl = 'https://api.igpsport.com';
  
  // Strava OAuth (需要替换为你的 Client ID)
  static const String stravaClientId = 'YOUR_STRAVA_CLIENT_ID';
  static const String stravaClientSecret = 'YOUR_STRAVA_CLIENT_SECRET';
  static const String stravaRedirectUri = 'ridepower://strava/callback';
  
  // Analysis Thresholds
  static const double segmentMatchThreshold = 0.7; // 70% match rate
  static const int minSegmentLength = 100; // meters
  static const int maxSegmentLength = 50000; // meters
  
  // Chart Colors
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF4CAF50;
  static const int dangerColorValue = 0xFFF44336;
  
  // Map Settings
  static const double defaultMapZoom = 13.0;
  static const double trackLineWidth = 4.0;
}
