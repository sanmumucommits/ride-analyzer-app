import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/ride_activity.dart';

class ActivityCard extends StatelessWidget {
  final RideActivity activity;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_bike,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatTime(activity.startTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSourceChip(context),
                ],
              ),
              const SizedBox(height: 16),
              // Stats Row
              Row(
                children: [
                  _StatItem(
                    icon: Icons.straighten,
                    value: '${activity.distanceKm.toStringAsFixed(1)} km',
                    label: 'Distance',
                  ),
                  _StatItem(
                    icon: Icons.timer,
                    value: _formatDuration(activity.duration),
                    label: 'Duration',
                  ),
                  _StatItem(
                    icon: Icons.trending_up,
                    value: '${activity.elevationGainMeters.round()} m',
                    label: 'Elevation',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Secondary Stats Row
              Row(
                children: [
                  _StatItem(
                    icon: Icons.speed,
                    value: '${activity.avgSpeedKmh.toStringAsFixed(1)} km/h',
                    label: 'Avg Speed',
                    small: true,
                  ),
                  if (activity.avgHeartRate != null)
                    _StatItem(
                      icon: Icons.favorite,
                      value: '${activity.avgHeartRate} bpm',
                      label: 'Avg HR',
                      small: true,
                      iconColor: Colors.red,
                    ),
                  if (activity.avgCadence != null)
                    _StatItem(
                      icon: Icons.rotate_right,
                      value: '${activity.avgCadence} rpm',
                      label: 'Cadence',
                      small: true,
                    ),
                  if (activity.avgPowerWatts != null)
                    _StatItem(
                      icon: Icons.bolt,
                      value: '${activity.avgPowerWatts!.round()} w',
                      label: 'Power',
                      small: true,
                      iconColor: Colors.amber,
                    ),
                ],
              ),
              // Upload Status
              if (activity.isUploadedToXingzhe)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_done,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Synced to Xingzhe',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceChip(BuildContext context) {
    Color chipColor;
    String label;

    switch (activity.source) {
      case 'wanlu':
        chipColor = Colors.orange;
        label = 'Wanlu';
        break;
      case 'igpsport':
        chipColor = Colors.blue;
        label = 'iGPS';
        break;
      case 'fitFile':
        chipColor = Colors.green;
        label = 'FIT';
        break;
      default:
        chipColor = Colors.grey;
        label = 'Manual';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
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
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool small;
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.small = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: small ? 16 : 20,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: small ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!small)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
