import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../../data/models/ride_activity.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/activity_provider.dart';
import '../analysis/analysis_screen.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key});

  static const String routeName = '/activity';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ModalRoute.of(context)!.settings.arguments as RideActivity?;

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity')),
        body: const Center(child: Text('Activity not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AnalysisScreen.routeName,
                arguments: activity,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'upload':
                  await _uploadToXingzhe(context, ref, activity);
                  break;
                case 'sync_strava':
                  await _syncToStrava(context, ref, activity);
                  break;
                case 'delete':
                  await _deleteActivity(context, ref, activity);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'upload',
                child: ListTile(
                  leading: Icon(Icons.cloud_upload),
                  title: Text('Upload to Xingzhe'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sync_strava',
                child: ListTile(
                  leading: Icon(Icons.sync),
                  title: Text('Sync to Strava'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Preview
            if (activity.trackPoints.isNotEmpty)
              SizedBox(
                height: 200,
                child: _MapPreview(trackPoints: activity.trackPoints),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: Colors.grey),
                      Text('No GPS data'),
                    ],
                  ),
                ),
              ),

            // Activity Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Info
                  _InfoCard(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(activity.startTime),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('HH:mm').format(activity.startTime)} - ${DateFormat('HH:mm').format(activity.endTime)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main Stats
                  _SectionTitle(title: 'Overview'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.straighten,
                          value: '${activity.distanceKm.toStringAsFixed(1)}',
                          unit: 'km',
                          label: 'Distance',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.timer,
                          value: _formatDuration(activity.duration),
                          label: 'Duration',
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up,
                          value: '${activity.elevationGainMeters.round()}',
                          unit: 'm',
                          label: 'Elevation Gain',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_down,
                          value: '${activity.elevationLossMeters.round()}',
                          unit: 'm',
                          label: 'Elevation Loss',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Speed Stats
                  _SectionTitle(title: 'Speed'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.speed,
                          value: '${activity.avgSpeedKmh.toStringAsFixed(1)}',
                          unit: 'km/h',
                          label: 'Average',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.flash_on,
                          value: '${activity.maxSpeedKmh.toStringAsFixed(1)}',
                          unit: 'km/h',
                          label: 'Maximum',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  // Power Stats (if available)
                  if (activity.avgPowerWatts != null) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Power'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bolt,
                            value: '${activity.avgPowerWatts!.round()}',
                            unit: 'w',
                            label: 'Average',
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bolt,
                            value: '${activity.maxPowerWatts?.round() ?? 0}',
                            unit: 'w',
                            label: 'Maximum',
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Heart Rate Stats (if available)
                  if (activity.avgHeartRate != null) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Heart Rate'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.favorite,
                            value: '${activity.avgHeartRate}',
                            unit: 'bpm',
                            label: 'Average',
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.favorite,
                            value: '${activity.maxHeartRate ?? 0}',
                            unit: 'bpm',
                            label: 'Maximum',
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Cadence Stats (if available)
                  if (activity.avgCadence != null) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Cadence'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.rotate_right,
                            value: '${activity.avgCadence}',
                            unit: 'rpm',
                            label: 'Average',
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.rotate_right,
                            value: '${activity.maxCadence ?? 0}',
                            unit: 'rpm',
                            label: 'Maximum',
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Strava Segments
                  if (activity.matchedSegments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Strava Segments'),
                    const SizedBox(height: 12),
                    ...activity.matchedSegments.map((segment) => Card(
                      child: ListTile(
                        leading: Icon(
                          segment.isPR ? Icons.emoji_events : Icons.flag,
                          color: segment.isPR ? Colors.amber : Colors.grey,
                        ),
                        title: Text(segment.name),
                        subtitle: Text(
                          '${segment.distanceKm.toStringAsFixed(1)} km • ${segment.elevationGainMeters.round()} m climb',
                        ),
                        trailing: segment.personalRecord != null
                          ? Text(
                              _formatDuration(segment.personalRecord!),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                      ),
                    )),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _syncToStrava(context, ref, activity),
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Strava'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _uploadToXingzhe(context, ref, activity),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload Xingzhe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _uploadToXingzhe(
    BuildContext context,
    WidgetRef ref,
    RideActivity activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload to Xingzhe'),
        content: const Text(
          'This will upload your activity to the Xingzhe (行者) app. '
          'Make sure you have the Xingzhe app installed and logged in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement Xingzhe upload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xingzhe upload feature coming soon!'),
        ),
      );
    }
  }

  Future<void> _syncToStrava(
    BuildContext context,
    WidgetRef ref,
    RideActivity activity,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Strava sync feature coming soon!'),
      ),
    );
  }

  Future<void> _deleteActivity(
    BuildContext context,
    WidgetRef ref,
    RideActivity activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text(
          'Are you sure you want to delete this activity? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(activityListProvider.notifier).deleteActivity(activity.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _MapPreview extends StatelessWidget {
  final List<dynamic> trackPoints;

  const _MapPreview({required this.trackPoints});

  @override
  Widget build(BuildContext context) {
    final latLngs = trackPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: latLngs.isNotEmpty ? latLngs.first : const LatLng(31.2304, 121.4737),
        initialZoom: 13,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ridepower.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: latLngs,
              color: AppTheme.primaryColor,
              strokeWidth: 4,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    this.unit = '',
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 2),
                    child: Text(
                      unit,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
