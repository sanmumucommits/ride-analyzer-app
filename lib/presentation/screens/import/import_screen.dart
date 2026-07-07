import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../providers/activity_provider.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  static const String routeName = '/import';

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _isImporting = false;
  String? _selectedSource;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Import Methods
            Text(
              'Choose Import Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // FIT File Import
            _ImportMethodCard(
              icon: Icons.file_present,
              title: 'Import FIT File',
              description: 'Select a .fit file from your device to import activity data',
              onTap: _isImporting ? null : () => _importFitFile(),
              isLoading: _isImporting && _selectedSource == 'fit',
            ),

            const SizedBox(height: 12),

            // Wanlu Import
            _ImportMethodCard(
              icon: Icons.cloud_sync,
              title: 'Wanlu Sports (顽鹿运动)',
              description: 'Sync activities from your Wanlu account',
              onTap: _isImporting ? null : () => _showWanluLogin(),
              isLoading: _isImporting && _selectedSource == 'wanlu',
            ),

            const SizedBox(height: 12),

            // iGPSSport Import
            _ImportMethodCard(
              icon: Icons.gps_fixed,
              title: 'iGPSSport',
              description: 'Sync activities from your iGPSSport device/account',
              onTap: _isImporting ? null : () => _showIgpsLogin(),
              isLoading: _isImporting && _selectedSource == 'igpsport',
            ),

            const SizedBox(height: 32),

            // Recent Imports
            Text(
              'Recent Imports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _RecentImportsList(),
          ],
        ),
      ),
    );
  }

  Future<void> _importFitFile() async {
    setState(() {
      _isImporting = true;
      _selectedSource = 'fit';
    });

    try {
      // Use FileType.any and filter manually for better Android compatibility
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // Filter only .fit files (case-insensitive)
        final fitFiles = result.files.where((file) {
          final ext = file.extension?.toLowerCase();
          final name = file.name.toLowerCase();
          return ext == 'fit' || name.endsWith('.fit');
        }).toList();

        if (fitFiles.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No .fit files found in selection'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        for (final file in fitFiles) {
          if (file.path != null) {
            // Import the file
            await ref.read(activityListProvider.notifier).importFromFit(file.path!);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully imported ${fitFiles.length} FIT file(s)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isImporting = false;
        _selectedSource = null;
      });
    }
  }

  void _showWanluLogin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_sync, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Login to Wanlu (顽鹿运动)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username / Email',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _loginWanlu(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Sync from Wanlu'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showIgpsLogin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Login to iGPSSport',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username / Email',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _loginIgps(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Sync from iGPSSport'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginWanlu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isImporting = true;
      _selectedSource = 'wanlu';
    });

    Navigator.pop(context);

    // TODO: Implement Wanlu API login and sync
    // This would typically:
    // 1. Call Wanlu API to authenticate
    // 2. Get list of activities
    // 3. Import each activity

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isImporting = false;
      _selectedSource = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wanlu sync feature coming soon!'),
        ),
      );
    }
  }

  Future<void> _loginIgps() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isImporting = true;
      _selectedSource = 'igpsport';
    });

    Navigator.pop(context);

    // TODO: Implement iGPSSport API login and sync
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isImporting = false;
      _selectedSource = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('iGPSSport sync feature coming soon!'),
        ),
      );
    }
  }
}

class _ImportMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ImportMethodCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
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
}

class _RecentImportsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityListProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No activities yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final recentActivities = activities.take(5).toList();

        return Column(
          children: recentActivities.map((activity) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: const Icon(Icons.directions_bike),
              ),
              title: Text(activity.name),
              subtitle: Text(
                '${activity.distanceKm.toStringAsFixed(1)} km • ${_formatDate(activity.startTime)}',
              ),
              trailing: _buildSourceChip(activity.source),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading activities')),
    );
  }

  Widget _buildSourceChip(String source) {
    Color chipColor;
    String label;

    switch (source) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
