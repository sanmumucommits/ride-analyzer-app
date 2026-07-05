import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../data/models/ride_activity.dart';
import '../../../data/models/geo_point.dart';
import '../../../core/theme/app_theme.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  static const String routeName = '/analysis';

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = ModalRoute.of(context)!.settings.arguments as RideActivity?;

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis')),
        body: const Center(child: Text('Activity not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Elevation'),
            Tab(text: 'Speed'),
            Tab(text: 'Power'),
            Tab(text: 'Heart Rate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ElevationTab(activity: activity),
          _SpeedTab(activity: activity),
          if (activity.avgPowerWatts != null)
            _PowerTab(activity: activity)
          else
            const _NoDataTab(message: 'No power data available'),
          if (activity.avgHeartRate != null)
            _HeartRateTab(activity: activity)
          else
            const _NoDataTab(message: 'No heart rate data available'),
        ],
      ),
    );
  }
}

class _ElevationTab extends StatelessWidget {
  final RideActivity activity;

  const _ElevationTab({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.trackPoints.isEmpty) {
      return const Center(child: Text('No GPS data available'));
    }

    // Calculate cumulative distance and elevation profile
    final spots = <FlSpot>[];
    double cumulativeDistance = 0;
    double? prevLat;
    double? prevLon;

    for (int i = 0; i < activity.trackPoints.length; i++) {
      final point = activity.trackPoints[i];
      
      if (prevLat != null && prevLon != null) {
        final dist = _calculateDistance(prevLat, prevLon, point.latitude, point.longitude);
        cumulativeDistance += dist;
      }
      
      if (point.altitudeMeters != null) {
        spots.add(FlSpot(cumulativeDistance / 1000, point.altitudeMeters!));
      }
      
      prevLat = point.latitude;
      prevLon = point.longitude;
    }

    final minElevation = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxElevation = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              _StatChip(
                label: 'Min',
                value: '${minElevation.round()} m',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Max',
                value: '${maxElevation.round()} m',
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Gain',
                value: '${activity.elevationGainMeters.round()} m',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Elevation Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elevation Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 50,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}m',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toStringAsFixed(1)}km',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.green,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.3),
                                  Colors.green.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minY: minElevation - 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = 
      _sin(dLat / 2) * _sin(dLat / 2) +
      _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
      _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  double _sin(double x) {
    while (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    while (x < -3.141592653589793) x += 2 * 3.141592653589793;
    double result = x;
    double term = x;
    for (int i = 1; i <= 7; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
  double _cos(double x) => _sin(x + 3.141592653589793 / 2);
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  double _atan(double x) => x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
}

class _SpeedTab extends StatelessWidget {
  final RideActivity activity;

  const _SpeedTab({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.trackPoints.isEmpty) {
      return const Center(child: Text('No GPS data available'));
    }

    final spots = <FlSpot>[];
    double timeSeconds = 0;
    final startTime = activity.trackPoints.first.timestamp;

    for (final point in activity.trackPoints) {
      if (point.timestamp != startTime) {
        timeSeconds += point.timestamp.difference(startTime).inSeconds.toDouble();
      }
      if (point.speedMps != null) {
        spots.add(FlSpot(timeSeconds / 60, point.speedKmh));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              _StatChip(
                label: 'Avg',
                value: '${activity.avgSpeedKmh.toStringAsFixed(1)} km/h',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Max',
                value: '${activity.maxSpeedKmh.toStringAsFixed(1)} km/h',
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Speed Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Speed Over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}m',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.blue,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.blue.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerTab extends StatelessWidget {
  final RideActivity activity;

  const _PowerTab({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.trackPoints.isEmpty) {
      return const Center(child: Text('No power data available'));
    }

    final spots = <FlSpot>[];
    double timeSeconds = 0;
    final startTime = activity.trackPoints.first.timestamp;

    for (final point in activity.trackPoints) {
      if (point.timestamp != startTime) {
        timeSeconds += point.timestamp.difference(startTime).inSeconds.toDouble();
      }
      if (point.power != null) {
        spots.add(FlSpot(timeSeconds / 60, point.power!));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              _StatChip(
                label: 'Avg',
                value: '${activity.avgPowerWatts?.round() ?? 0} w',
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Max',
                value: '${activity.maxPowerWatts?.round() ?? 0} w',
                color: Colors.deepOrange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Power Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Power Over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}w',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}m',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.amber,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.3),
                                  Colors.amber.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRateTab extends StatelessWidget {
  final RideActivity activity;

  const _HeartRateTab({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.trackPoints.isEmpty) {
      return const Center(child: Text('No heart rate data available'));
    }

    final spots = <FlSpot>[];
    double timeSeconds = 0;
    final startTime = activity.trackPoints.first.timestamp;

    for (final point in activity.trackPoints) {
      if (point.timestamp != startTime) {
        timeSeconds += point.timestamp.difference(startTime).inSeconds.toDouble();
      }
      if (point.heartRate != null) {
        spots.add(FlSpot(timeSeconds / 60, point.heartRate!.toDouble()));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              _StatChip(
                label: 'Avg',
                value: '${activity.avgHeartRate} bpm',
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Max',
                value: '${activity.maxHeartRate ?? 0} bpm',
                color: Colors.pink,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Heart Rate Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart Rate Over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}m',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.red,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.3),
                                  Colors.red.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataTab extends StatelessWidget {
  final String message;

  const _NoDataTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
