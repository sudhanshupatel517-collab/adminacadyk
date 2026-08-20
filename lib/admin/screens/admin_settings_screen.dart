import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_settings_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/admin_form_field.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

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

    if (provider.isLoading) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.text(isDark)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          const AdminSectionHeader(
            title: 'Institutional Settings & Controls',
            padding: EdgeInsets.only(bottom: 16),
          ),

          // Banners
          if (provider.successMessage != null)
            _buildBanner(provider.successMessage!, AppColors.success, isDark),
          if (provider.error != null)
            _buildBanner(provider.error!, AppColors.error, isDark),

          // App Settings Section
          _buildSection('Platform Metadata', isDark, [
            AdminFormRow(children: [
              AdminTextField(
                label: 'Platform Name',
                value: settings.appName,
                onChanged: (v) => provider.updateSettings(settings.copyWith(appName: v)),
                enabled: isSuperAdmin,
              ),
              AdminTextField(
                label: 'Institutional Tagline',
                value: settings.tagline,
                onChanged: (v) => provider.updateSettings(settings.copyWith(tagline: v)),
                enabled: isSuperAdmin,
              ),
            ]),
            AdminFormRow(children: [
              AdminTextField(
                label: 'Administrative Support Email',
                value: settings.contactEmail,
                onChanged: (v) => provider.updateSettings(settings.copyWith(contactEmail: v)),
                enabled: isSuperAdmin,
              ),
            ]),
          ]),

          const SizedBox(height: 20),

          // Feature Flags Section
          _buildSection('Module Controls & Feature Flags', isDark, [
            AdminSwitchField(
              label: 'Maintenance Mode',
              subtitle: 'Restricts user panel access for scheduled platform maintenance',
              value: settings.maintenanceMode,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(maintenanceMode: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'AI Content Recommendations',
              subtitle: 'Enable smart course and academic post suggestions',
              value: settings.enableAIRecommendations,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableAIRecommendations: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'Real-time WebSocket Chat',
              subtitle: 'Campus peer-to-peer and club group messaging',
              value: settings.enableRealtimeChat,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableRealtimeChat: v)) : null,
            ),
            const SizedBox(height: 8),
            AdminSwitchField(
              label: 'Campus Startups & Incubator',
              subtitle: 'Student entrepreneurship & project showcase directory',
              value: settings.enableStartups,
              onChanged: isSuperAdmin ? (v) => provider.updateSettings(settings.copyWith(enableStartups: v)) : null,
            ),
          ]),

          const SizedBox(height: 20),

          // System Info
          _buildSection('Infrastructure & Build', isDark, [
            _buildInfoRow('Environment', 'Production (AWS Cloud)', isDark),
            _buildInfoRow('API Endpoint', 'http://15.252.182.118:8080/api/v1', isDark),
            _buildInfoRow('Database', 'PostgreSQL 16 (Relational)', isDark),
            _buildInfoRow('Backend Service', 'Spring Boot 3.3.0 · Kotlin 1.9', isDark),
            _buildInfoRow('Admin Interface', 'v1.0.0 (Enterprise Academic Edition)', isDark),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    final borderColor = AppColors.borderSubtle(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSec(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String message, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}