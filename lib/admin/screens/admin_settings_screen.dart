import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_settings_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_mock_data.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _appNameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSettingsProvider>().loadSettings().then((_) {
        final s = context.read<AdminSettingsProvider>().settings;
        if (s != null) {
          _appNameCtrl.text = s.appName;
          _taglineCtrl.text = s.tagline;
          _emailCtrl.text = s.contactEmail;
        }
      });
    });
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _taglineCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminSettingsProvider>();
    final isSuperAdmin = context.watch<AdminAuthProvider>().isSuperAdmin;
    final settings = provider.settings;
    final cardBg = isDark ? const Color(0xFF13171F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    if (provider.isLoading || settings == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feedback Notifications
          if (provider.successMessage != null)
            _buildBanner(provider.successMessage!, const Color(0xFF059669), isDark),
          if (provider.error != null)
            _buildBanner(provider.error!, const Color(0xFFDC2626), isDark),

          // Institution Configuration Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institutional Configuration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                const SizedBox(height: 4),
                Text('Configure university details, campus contact info, and branding labels.', style: TextStyle(fontSize: 12, color: textSecondary)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _appNameCtrl,
                  enabled: isSuperAdmin,
                  decoration: const InputDecoration(labelText: 'Platform Name', border: OutlineInputBorder()),
                  onChanged: (v) => provider.updateSettings(settings.copyWith(appName: v)),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _taglineCtrl,
                  enabled: isSuperAdmin,
                  decoration: const InputDecoration(labelText: 'Campus Subtitle / Tagline', border: OutlineInputBorder()),
                  onChanged: (v) => provider.updateSettings(settings.copyWith(tagline: v)),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  enabled: isSuperAdmin,
                  decoration: const InputDecoration(labelText: 'Administrative Contact Email', border: OutlineInputBorder()),
                  onChanged: (v) => provider.updateSettings(settings.copyWith(contactEmail: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Feature Flags & Security Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Modules & Governance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
                const SizedBox(height: 4),
                Text('Enable or suspend specific campus modules in real-time.', style: TextStyle(fontSize: 12, color: textSecondary)),
                const SizedBox(height: 16),
                _buildSwitchRow('Maintenance Mode', 'Temporarily restrict student access for scheduled updates', settings.maintenanceMode, isSuperAdmin, (v) => provider.updateSettings(settings.copyWith(maintenanceMode: v)), textPrimary, textSecondary),
                Divider(color: borderColor, height: 20),
                _buildSwitchRow('Student Startup Showcase', 'Allow students to post project and venture proposals', settings.enableStartups, isSuperAdmin, (v) => provider.updateSettings(settings.copyWith(enableStartups: v)), textPrimary, textSecondary),
                Divider(color: borderColor, height: 20),
                _buildSwitchRow('Real-time Messaging & Chat', 'Enable peer-to-peer campus communication channels', settings.enableRealtimeChat, isSuperAdmin, (v) => provider.updateSettings(settings.copyWith(enableRealtimeChat: v)), textPrimary, textSecondary),
                Divider(color: borderColor, height: 20),
                _buildSwitchRow('Academic Leaderboard', 'Gamified academic contributions & recognition points', settings.enableLeaderboard, isSuperAdmin, (v) => provider.updateSettings(settings.copyWith(enableLeaderboard: v)), textPrimary, textSecondary),
                Divider(color: borderColor, height: 20),
                _buildSwitchRow('Campus Events & Clubs', 'Enable club management and calendar discovery', settings.enableEvents, isSuperAdmin, (v) => provider.updateSettings(settings.copyWith(enableEvents: v)), textPrimary, textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          if (isSuperAdmin)
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: provider.isSaving ? null : () => provider.saveSettings(),
                  child: provider.isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textSecondary,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () {
                    provider.updateSettings(AdminMockData.defaultSettings);
                    _appNameCtrl.text = AdminMockData.defaultSettings.appName;
                    _taglineCtrl.text = AdminMockData.defaultSettings.tagline;
                    _emailCtrl.text = AdminMockData.defaultSettings.contactEmail;
                  },
                  child: const Text('Reset Defaults', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, bool enabled, ValueChanged<bool> onChanged, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: const Color(0xFF0A66C2),
        ),
      ],
    );
  }

  Widget _buildBanner(String msg, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Text(msg, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}