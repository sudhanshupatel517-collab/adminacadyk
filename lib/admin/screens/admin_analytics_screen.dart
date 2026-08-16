import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminDashboardProvider>();
    final stats = provider.stats;

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
                    'Analytics & Institutional Reports',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Metrics on campus student engagement, retention, and content lifecycle',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating institutional analytics report (PDF/CSV)...')),
                  );
                },
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('Export Report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Metrics Summary Cards
          Row(
            children: [
              Expanded(child: _buildMetricCard(isDark, 'User Retention', '84.2%', '+3.1% this month', const Color(0xFF00BA7C))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard(isDark, 'Avg Daily Active', '${stats?.activeUsers ?? 10}', 'High Engagement', const Color(0xFF1565C0))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard(isDark, 'Posts / Student', '3.4', 'Across 6 departments', const Color(0xFF7B1FA2))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard(isDark, 'Mod Resolution', '99.1%', '< 2 hour resolution', const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 24),

          // Enrollment Trend & Content Distribution
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildGrowthChart(isDark)),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildCategoryBreakdown(isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(bool isDark, String label, String value, String subtitle, Color accent) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(bool isDark) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    final terms = [
      {'term': 'Fall 2024', 'users': 420},
      {'term': 'Spring 2025', 'users': 680},
      {'term': 'Fall 2025', 'users': 950},
      {'term': 'Spring 2026', 'users': 1247},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Term Enrollment Growth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
          const SizedBox(height: 24),
          ...terms.map((t) {
            final double pct = (t['users'] as int) / 1300.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t['term'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                      Text('${t['users']} students', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE),
                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(bool isDark) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    final cats = [
      {'name': 'Research Papers', 'pct': 0.45, 'color': const Color(0xFF1565C0)},
      {'name': 'Career & Internships', 'pct': 0.28, 'color': const Color(0xFF00BA7C)},
      {'name': 'Club Announcements', 'pct': 0.17, 'color': const Color(0xFF7B1FA2)},
      {'name': 'General Discussions', 'pct': 0.10, 'color': const Color(0xFFF59E0B)},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Content Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
          const SizedBox(height: 20),
          ...cats.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: c['color'] as Color)),
                const SizedBox(width: 10),
                Expanded(child: Text(c['name'] as String, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)))),
                Text('${((c['pct'] as double) * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}