import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/strava_segment.dart';

class SegmentsScreen extends ConsumerStatefulWidget {
  const SegmentsScreen({super.key});

  static const String routeName = '/segments';

  @override
  ConsumerState<SegmentsScreen> createState() => _SegmentsScreenState();
}

class _SegmentsScreenState extends ConsumerState<SegmentsScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  String _filter = 'all'; // all, pr, ranked

  @override
  void initState() {
    super.initState();
    // Check if Strava is connected
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    // TODO: Check if Strava token exists
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strava Segments'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshSegments,
            ),
        ],
      ),
      body: _isConnected
          ? _buildSegmentsList()
          : _buildConnectionPrompt(),
    );
  }

  Widget _buildConnectionPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.link,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Connect to Strava',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Link your Strava account to see your segment PRs and '
              'automatically match activities to segments.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _connectStrava,
                icon: const Icon(Icons.link),
                label: const Text('Connect Strava'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentsList() {
    // Mock segments for demonstration
    final segments = _getMockSegments();

    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: _filter == 'all',
                onSelected: () => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'PRs',
                isSelected: _filter == 'pr',
                onSelected: () => setState(() => _filter = 'pr'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Ranked',
                isSelected: _filter == 'ranked',
                onSelected: () => setState(() => _filter = 'ranked'),
              ),
            ],
          ),
        ),

        // Segments List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : segments.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: segments.length,
                      itemBuilder: (context, index) {
                        final segment = segments[index];
                        return _SegmentCard(
                          segment: segment,
                          onTap: () => _showSegmentDetails(segment),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No segments found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some rides to earn segment PRs!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<StravaSegment> _getMockSegments() {
    return [
      const StravaSegment(
        id: '1',
        name: 'Huangpu River Bridge Climb',
        distanceMeters: 2500,
        elevationGainMeters: 45,
        avgGrade: 1.8,
        personalRecordSeconds: 285,
        isPR: true,
        rank: 150,
      ),
      const StravaSegment(
        id: '2',
        name: 'Century Avenue Sprint',
        distanceMeters: 800,
        elevationGainMeters: 12,
        avgGrade: 1.5,
        personalRecordSeconds: 78,
        isPR: false,
        rank: 45,
      ),
      const StravaSegment(
        id: '3',
        name: 'West Lake Loop',
        distanceMeters: 15000,
        elevationGainMeters: 120,
        avgGrade: 0.8,
        personalRecordSeconds: 2400,
        isPR: true,
        rank: 320,
      ),
      const StravaSegment(
        id: '4',
        name: 'Mountain Pass Challenge',
        distanceMeters: 5200,
        elevationGainMeters: 280,
        avgGrade: 5.4,
        personalRecordSeconds: 720,
        isPR: false,
        rank: 890,
      ),
    ];
  }

  Future<void> _connectStrava() async {
    setState(() => _isLoading = true);

    // TODO: Implement Strava OAuth flow
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isConnected = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Strava connected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _refreshSegments() async {
    setState(() => _isLoading = true);

    // TODO: Fetch segments from Strava API
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  void _showSegmentDetails(StravaSegment segment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  if (segment.isPR)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          segment.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (segment.isPR)
                          const Text(
                            'Personal Record!',
                            style: TextStyle(color: Colors.amber),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.straighten,
                      value: '${segment.distanceKm.toStringAsFixed(1)} km',
                      label: 'Distance',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up,
                      value: '${segment.elevationGainMeters.round()} m',
                      label: 'Elevation',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.show_chart,
                      value: '${segment.avgGrade?.toStringAsFixed(1) ?? 0}%',
                      label: 'Avg Grade',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.leaderboard,
                      value: segment.rank != null ? '#${segment.rank}' : '-',
                      label: 'Rank',
                    ),
                  ),
                ],
              ),

              if (segment.personalRecord != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Personal Record',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 32, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          _formatDuration(segment.personalRecord!),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

class _SegmentCard extends StatelessWidget {
  final StravaSegment segment;
  final VoidCallback onTap;

  const _SegmentCard({
    required this.segment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // PR Badge or Rank
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: segment.isPR
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (segment.isPR)
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 24,
                      )
                    else
                      Text(
                        '#${segment.rank ?? '-'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Segment Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${segment.distanceKm.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${segment.elevationGainMeters.round()} m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // PR Time
              if (segment.personalRecord != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(segment.personalRecord!),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (segment.isPR)
                      const Text(
                        'PR',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
