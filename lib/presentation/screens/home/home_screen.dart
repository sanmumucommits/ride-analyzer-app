import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/ride_activity.dart';
import '../../providers/activity_provider.dart';
import '../activity_detail/activity_detail_screen.dart';
import '../import/import_screen.dart';
import '../settings/settings_screen.dart';
import '../segments/segments_screen.dart';
import 'widgets/activity_card.dart';
import 'widgets/stats_summary_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load activities on init
    Future.microtask(() {
      ref.read(activityListProvider.notifier).loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RidePower'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(activityListProvider.notifier).loadActivities();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ActivitiesTab(),
          _SegmentsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '活动',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '赛段',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(ImportScreen.routeName);
        },
        icon: const Icon(Icons.add),
        label: const Text('导入'),
      ),
    );
  }
}

class _ActivitiesTab extends ConsumerWidget {
  const _ActivitiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityListProvider);
    final summary = ref.watch(activitySummaryProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return _EmptyState();
        }

        // Group activities by date
        final groupedActivities = _groupActivitiesByDate(activities);

        return CustomScrollView(
          slivers: [
            // Summary Stats
            SliverToBoxAdapter(
              child: StatsSummaryCard(summary: summary),
            ),
            // Activity List
            ...groupedActivities.entries.map((entry) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _DateHeaderDelegate(date: entry.key),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final activity = entry.value[index];
                        return ActivityCard(
                          activity: activity,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ActivityDetailScreen.routeName,
                              arguments: activity,
                            );
                          },
                        );
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ],
              );
            }),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(activityListProvider.notifier).loadActivities();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<RideActivity>> _groupActivitiesByDate(
    List<RideActivity> activities,
  ) {
    final grouped = <DateTime, List<RideActivity>>{};
    for (final activity in activities) {
      final date = DateTime(
        activity.startTime.year,
        activity.startTime.month,
        activity.startTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(activity);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime date;

  _DateHeaderDelegate({required this.date});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String dateText;
    if (date == today) {
      dateText = 'Today';
    } else if (date == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMMM d').format(date);
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        dateText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant _DateHeaderDelegate oldDelegate) {
    return date != oldDelegate.date;
  }
}

class _SegmentsTab extends StatelessWidget {
  const _SegmentsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Strava 赛段',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your Strava account\nto see your segment PRs',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(SegmentsScreen.routeName);
            },
            icon: const Icon(Icons.link),
            label: const Text('Connect Strava'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(ImportScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'RidePower',
                applicationVersion: '1.0.0',
                applicationLegalese: 'A cycling data analysis app',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bike,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No Activities Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Import your cycling data to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(ImportScreen.routeName);
            },
            icon: const Icon(Icons.add),
            label: const Text('Import Data'),
          ),
        ],
      ),
    );
  }
}
