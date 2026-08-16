import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_settings_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/admin_form_field.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminSettingsProvider>();
    final isSuperAdmin = context.watch<AdminAuthProvider>().isSuperAdmin;
    final settings = provider.settings;

    if (provider.isLoading || settings == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success/Error messages
          if (provider.successMessage != null)
            _buildBanner(provider.successMessage!, const Color(0xFF00BA7C), isDark),
          if (provider.error != null)
            _buildBanner(provider.error!, const Color(0xFFF87171), isDark),

          // App Settings
          _buildSection('Application Settings', isDark, [
            AdminFormRow(children: [
              AdminTextField(
                label: 'App Name',
                value: settings.appName,
                onChanged: (v) => provider.updateSettings(settings.copyWith(appName: v)),
                enabled: isSuperAdmin,
              ),
              AdminTextField(
                label: 'Tagline',
                value: settings.tagline,
                onChanged: (v) => provider.updateSettings(settings.copyWith(tagline: v)),
                enabled: isSuperAdmin,
              ),
            ]),
            AdminFormRow(children: [
              AdminTextField(
                label: 'Contact Email',
                value: settings.contactEmail,
                onChanged: (v) => provider.updateSettings(settings.copyWith(contactEmail: v)),
                enabled: isSuperAdmin,
              ),
            ]),
          ]),

          const SizedBox(height: 24),

          // Feature Flags
          _buildSection('Feature Flags', isDark, [
            AdminSwitchField(
              label: 'Maintenance Mode',
              subtitle: 'Disables the app for all users',
              value: settings.maintenanceMode,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(maintenanceMode: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'AI Recommendations',
              subtitle: 'Enable AI-powered content suggestions',
              value: settings.enableAIRecommendations,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableAIRecommendations: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'Real-time Chat',
              subtitle: 'WebSocket-based messaging',
              value: settings.enableRealtimeChat,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableRealtimeChat: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'Startups',
              subtitle: 'Student startup showcase feature',
              value: settings.enableStartups,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableStartups: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'Leaderboard',
              subtitle: 'Gamified ranking system',
              value: settings.enableLeaderboard,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableLeaderboard: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'Events',
              subtitle: 'Campus event discovery',
              value: settings.enableEvents,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableEvents: v)) : null,
            ),
          ]),

          if (isSuperAdmin) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: provider.isSaving ? null : () => provider.saveSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: provider.isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          )),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBanner(String message, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(message, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }
}