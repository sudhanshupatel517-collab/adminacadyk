import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_section_header.dart';
import '../data/admin_service.dart';
import '../../app/theme/app_colors.dart';

/// Mature, Institutional Enterprise Dashboard for Acadyk Admin Panel.
/// Clean visual hierarchy, text-first presentation, clear data tables, and authentic administrative style.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

    if (provider.state == LoadState.loading) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.text(isDark),
          ),
        ),
      );
    }

    if (provider.state == LoadState.error) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load dashboard data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(isDark),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                provider.error ?? 'Please check network connection or try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSec(isDark),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => provider.loadDashboard(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = provider.stats;
    if (stats == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              AdminSectionHeader(
                title: 'System Overview',
                padding: const EdgeInsets.only(bottom: 16),
                trailing: OutlinedButton(
                  onPressed: () {
                    context.read<AdminDashboardProvider>().loadDashboard();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dashboard data refreshed.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Refresh'),
                ),
              ),

              // Metric Blocks Grid
              _buildStatGrid(stats, isDark, constraints.maxWidth),
              const SizedBox(height: 24),

              // Main Information Columns
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildRecentActivity(isDark, provider)),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildPlatformOverview(isDark, stats),
                          const SizedBox(height: 20),
                          _buildQuickActions(isDark),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRecentActivity(isDark, provider),
                    const SizedBox(height: 20),
                    _buildPlatformOverview(isDark, stats),
                    const SizedBox(height: 20),
                    _buildQuickActions(isDark),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatGrid(dynamic stats, bool isDark, double width) {
    final isMobile = width < AdminBreakpoints.mobile;
    final cards = [
      AdminStatCard(
        title: 'Total Users',
        value: '${stats.totalUsers}',
        subtitle: isMobile
            ? '${stats.totalStudents} st · ${stats.totalFaculty} fac'
            : '${stats.totalStudents} students · ${stats.totalFaculty} faculty',
      ),
      AdminStatCard(
        title: 'Active Users',
        value: '${stats.activeUsers}',
        subtitle: '${((stats.activeUsers / (stats.totalUsers > 0 ? stats.totalUsers : 1)) * 100).toStringAsFixed(0)}% active rate',
      ),
      AdminStatCard(
        title: 'Campus Events',
        value: '${stats.totalEvents}',
        subtitle: isMobile ? 'Published' : 'Hackathons & workshops',
      ),
      AdminStatCard(
        title: 'Clubs & Teams',
        value: '${stats.totalOrganizations}',
        subtitle: '${stats.totalClubs} active clubs',
      ),
    ];

    int crossAxisCount;
    double childAspectRatio;

    if (width >= AdminBreakpoints.tablet) {
      crossAxisCount = 4;
      childAspectRatio = 1.65;
    } else if (width >= AdminBreakpoints.mobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.7;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.35;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildRecentActivity(bool isDark, AdminDashboardProvider provider) {
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);
    final rowDividerColor = AppColors.borderSubtle(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Text(
                  'Recent Audit Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(isDark),
                  ),
                ),
                const Spacer(),
                Text(
                  '${provider.recentActivity.length} recorded',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMut(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),

          // Activity Rows
          if (provider.recentActivity.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No recent activity recorded.',
                  style: TextStyle(
                    color: AppColors.textMut(isDark),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.recentActivity.length,
              separatorBuilder: (_, __) => Container(height: 1, color: rowDividerColor),
              itemBuilder: (context, index) {
                final entry = provider.recentActivity[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  entry.action,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text(isDark),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '· ${entry.performedBy}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMut(isDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${entry.target}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSec(isDark),
                              ),
                            ),
                            if (entry.reason != null && entry.reason!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Note: ${entry.reason}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textMut(isDark),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        _formatTimestamp(entry.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMut(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformOverview(bool isDark, dynamic stats) {
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);
    final rowDividerColor = AppColors.borderSubtle(isDark);

    final items = [
      {'label': 'Campus Notices', 'value': '${stats.totalNotices}'},
      {'label': 'Total Posts Moderated', 'value': '${stats.totalPosts}'},
      {'label': 'Pending Flagged Content', 'value': '${stats.pendingReports}'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Text(
              'Platform Overview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text(isDark),
              ),
            ),
          ),
          Container(height: 1, color: borderColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Container(height: 1, color: rowDividerColor),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSec(isDark),
                        ),
                      ),
                    ),
                    Text(
                      item['value'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(isDark),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            isDark: isDark,
            label: 'Export Users Directory (CSV)',
            onTap: () {
              final csv = AdminService.generateUsersCsv();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Generated CSV export with ${csv.split("\n").length - 1} records.'),
                backgroundColor: AppColors.success,
              ));
            },
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            isDark: isDark,
            label: 'Refresh Platform Metrics',
            onTap: () {
              context.read<AdminDashboardProvider>().loadDashboard();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Dashboard statistics refreshed.'),
                duration: Duration(seconds: 1),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required String label,
    required VoidCallback onTap,
  }) {
    final borderColor = AppColors.border(isDark);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt(isDark),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text(isDark),
                  ),
                ),
              ),
              Text(
                'Execute',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSec(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}