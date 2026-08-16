import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_settings_provider.dart';
import '../providers/admin_auth_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _emailController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSettingsProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminSettingsProvider>();
    final auth = context.watch<AdminAuthProvider>();
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    if (provider.state == SettingsLoadState.loaded && !_initialized) {
      _nameController.text = provider.settings.appName;
      _taglineController.text = provider.settings.tagline;
      _emailController.text = provider.settings.contactEmail;
      _initialized = true;
    }

    final settings = provider.settings;
    final isSuperAdmin = auth.isSuperAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Settings & Governance',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Global platform configurations, feature switches, and administrative parameters',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await provider.resetDefaults();
                      _initialized = false;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Default configurations restored.')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reset Defaults'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: provider.state == SettingsLoadState.saving
                        ? null
                        : () async {
                            final updated = settings.copyWith(
                              appName: _nameController.text.trim(),
                              tagline: _taglineController.text.trim(),
                              contactEmail: _emailController.text.trim(),
                            );
                            provider.updateSettings(updated);
                            final success = await provider.saveSettings();
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Settings saved successfully.')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: provider.state == SettingsLoadState.saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Platform General Identity Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Identity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Platform Name'),
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _taglineController,
                  decoration: const InputDecoration(labelText: 'Tagline'),
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Support Contact Email'),
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feature Switches Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feature Modules & Platform Governance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  isDark,
                  'Maintenance Mode',
                  'Temporarily restrict regular student/faculty access while maintenance occurs',
                  settings.maintenanceMode,
                  (v) => provider.updateSettings(settings.copyWith(maintenanceMode: v)),
                ),
                _buildSwitchTile(
                  isDark,
                  'AI Recommendations',
                  'Enable machine learning opportunity matching for students',
                  settings.enableAIRecommendations,
                  (v) => provider.updateSettings(settings.copyWith(enableAIRecommendations: v)),
                ),
                _buildSwitchTile(
                  isDark,
                  'Real-time Messaging',
                  'Enable direct peer-to-peer and club group chats',
                  settings.enableRealtimeChat,
                  (v) => provider.updateSettings(settings.copyWith(enableRealtimeChat: v)),
                ),
                _buildSwitchTile(
                  isDark,
                  'Startup & Incubator Showcase',
                  'Allow student entrepreneurs to submit and showcase campus ventures',
                  settings.enableStartups,
                  (v) => provider.updateSettings(settings.copyWith(enableStartups: v)),
                ),
                _buildSwitchTile(
                  isDark,
                  'Campus Events',
                  'Allow clubs to schedule public campus calendar events',
                  settings.enableEvents,
                  (v) => provider.updateSettings(settings.copyWith(enableEvents: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(bool isDark, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF00BA7C),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}