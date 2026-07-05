import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/activity_detail/activity_detail_screen.dart';
import 'presentation/screens/analysis/analysis_screen.dart';
import 'presentation/screens/import/import_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/segments/segments_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

class RideAnalyzerApp extends ConsumerWidget {
  const RideAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RidePower',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        ActivityDetailScreen.routeName: (context) => const ActivityDetailScreen(),
        AnalysisScreen.routeName: (context) => const AnalysisScreen(),
        ImportScreen.routeName: (context) => const ImportScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        SegmentsScreen.routeName: (context) => const SegmentsScreen(),
      },
    );
  }
}
