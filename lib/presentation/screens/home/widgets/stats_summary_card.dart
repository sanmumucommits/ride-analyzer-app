import 'package:flutter/material.dart';

import '../../../../data/models/ride_activity.dart';
import '../../../providers/activity_provider.dart';

class StatsSummaryCard extends StatelessWidget {
  final ActivitySummary summary;

  const StatsSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.directions_bike,
                    value: summary.totalRides.toString(),
                    label: 'Rides',
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.straighten,
                    value: '${(summary.totalDistance / 1000).toStringAsFixed(0)} km',
                    label: 'Distance',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.timer,
                    value: _formatDuration(summary.totalDuration),
                    label: 'Time',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.trending_up,
                    value: '${summary.totalElevation.round()} m',
                    label: 'Elevation',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
