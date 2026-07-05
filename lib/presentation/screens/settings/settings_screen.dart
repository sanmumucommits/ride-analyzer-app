import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isStravaConnected = false;
  bool _autoSyncWanlu = false;
  bool _autoSyncIgps = false;
  String _units = 'metric';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences
    // This would be implemented with actual SharedPreferences access
    setState(() {
      _isStravaConnected = false;
      _autoSyncWanlu = false;
      _autoSyncIgps = false;
      _units = 'metric';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.link, color: Colors.white),
            ),
            title: const Text('Strava'),
            subtitle: Text(
              _isStravaConnected ? 'Connected' : 'Not connected',
            ),
            trailing: ElevatedButton(
              onPressed: _isStravaConnected ? _disconnectStrava : _connectStrava,
              child: Text(_isStravaConnected ? 'Disconnect' : 'Connect'),
            ),
          ),

          const Divider(),

          // Data Sources Section
          _SectionHeader(title: 'Data Sources'),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_sync),
            title: const Text('Auto-sync Wanlu (顽鹿运动)'),
            subtitle: const Text('Automatically sync activities'),
            value: _autoSyncWanlu,
            onChanged: (value) {
              setState(() => _autoSyncWanlu = value);
              _saveSettings();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.gps_fixed),
            title: const Text('Auto-sync iGPSSport'),
            subtitle: const Text('Automatically sync activities'),
            value: _autoSyncIgps,
            onChanged: (value) {
              setState(() => _autoSyncIgps = value);
              _saveSettings();
            },
          ),

          const Divider(),

          // Upload Section
          _SectionHeader(title: 'Upload'),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Upload to Xingzhe (行者)'),
            subtitle: const Text('Configure auto-upload settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showXingzheSettings(),
          ),

          const Divider(),

          // Units Section
          _SectionHeader(title: 'Units'),
          RadioListTile<String>(
            title: const Text('Metric (km, m)'),
            value: 'metric',
            groupValue: _units,
            onChanged: (value) {
              setState(() => _units = value!);
              _saveSettings();
            },
          ),
          RadioListTile<String>(
            title: const Text('Imperial (mi, ft)'),
            value: 'imperial',
            groupValue: _units,
            onChanged: (value) {
              setState(() => _units = value!);
              _saveSettings();
            },
          ),

          const Divider(),

          // About Section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTermsOfService(),
          ),

          const Divider(),

          // Danger Zone
          _SectionHeader(title: 'Danger Zone'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Delete all activities and settings'),
            onTap: () => _showClearDataDialog(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _connectStrava() async {
    // TODO: Implement Strava OAuth flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Strava connection feature coming soon!'),
      ),
    );
  }

  Future<void> _disconnectStrava() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Strava'),
        content: const Text(
          'Are you sure you want to disconnect your Strava account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isStravaConnected = false);
      _saveSettings();
    }
  }

  void _showXingzheSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xingzhe (行者) Upload Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-upload to Xingzhe'),
              subtitle: const Text('Automatically upload new activities'),
              value: false,
              onChanged: (value) {
                // TODO: Implement auto-upload setting
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xingzhe settings feature coming soon!'),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'RidePower respects your privacy.\n\n'
            'We collect activity data to provide analysis features. '
            'Your data is stored locally on your device and synced to '
            'third-party services only with your consent.\n\n'
            'For Strava integration, we access your activities and segments '
            'as per Strava\'s API terms.\n\n'
            'For Xingzhe integration, activities are uploaded to your '
            'Xingzhe account.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using RidePower, you agree to the following terms:\n\n'
            '1. Use the app at your own risk.\n'
            '2. Activity data accuracy depends on your device sensors.\n'
            '3. Third-party integrations are subject to their respective '
            'terms of service.\n'
            '4. We are not responsible for data loss.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your activities and settings. '
          'This action cannot be undone.\n\n'
          'Are you sure?',
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
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Clear all data from Hive and SharedPreferences
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared'),
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    // TODO: Save settings to SharedPreferences
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
