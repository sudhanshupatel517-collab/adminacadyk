import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_responsive.dart';
import '../data/admin_service.dart';

/// Refined Enterprise Dashboard for Acadyk Admin Panel.
/// Designed with human-product discipline: clean hierarchy, 1px subtle borders,
/// high information density, and restrained academic aesthetic.
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
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
              Icon(Icons.cloud_off_rounded, size: 36, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                'Unable to load dashboard data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                provider.error ?? 'Please check network connection or try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => provider.loadDashboard(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
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
        icon: Icons.people_alt_outlined,
        iconColor: const Color(0xFF2563EB),
        subtitle: isMobile
            ? '${stats.totalStudents} st · ${stats.totalFaculty} fac'
            : '${stats.totalStudents} students · ${stats.totalFaculty} faculty',
      ),
      AdminStatCard(
        title: 'Active Users',
        value: '${stats.activeUsers}',
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF16A34A),
        subtitle: '${((stats.activeUsers / (stats.totalUsers > 0 ? stats.totalUsers : 1)) * 100).toStringAsFixed(0)}% active rate',
      ),
      AdminStatCard(
        title: 'Campus Events',
        value: '${stats.totalEvents}',
        icon: Icons.event_outlined,
        iconColor: const Color(0xFFD97706),
        subtitle: isMobile ? 'Published' : 'Hackathons & workshops',
      ),
      AdminStatCard(
        title: 'Clubs & Teams',
        value: '${stats.totalOrganizations}',
        icon: Icons.groups_outlined,
        iconColor: const Color(0xFF7C3AED),
        subtitle: '${stats.totalClubs} active clubs',
      ),
    ];

    int crossAxisCount;
    double childAspectRatio;

    if (width >= AdminBreakpoints.tablet) {
      crossAxisCount = 4;
      childAspectRatio = 1.6;
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
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildRecentActivity(bool isDark, AdminDashboardProvider provider) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final rowDividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  'Recent Audit Activity',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFBBF7D0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live Stream',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),

          // Activity Rows
          if (provider.recentActivity.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No recent activity recorded.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
                IconData actionIcon;
                Color actionColor;

                switch (entry.action.toLowerCase()) {
                  case 'user suspended':
                    actionIcon = Icons.block_rounded;
                    actionColor = const Color(0xFFD97706);
                    break;
                  case 'content flagged':
                  case 'content removed':
                    actionIcon = Icons.flag_outlined;
                    actionColor = const Color(0xFFDC2626);
                    break;
                  case 'new admin added':
                  case 'user added':
                    actionIcon = Icons.person_add_outlined;
                    actionColor = const Color(0xFF16A34A);
                    break;
                  case 'event created':
                  case 'event published':
                    actionIcon = Icons.event_available_outlined;
                    actionColor = const Color(0xFF2563EB);
                    break;
                  case 'notice published':
                    actionIcon = Icons.campaign_outlined;
                    actionColor = const Color(0xFF7C3AED);
                    break;
                  default:
                    actionIcon = Icons.info_outline_rounded;
                    actionColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(actionIcon, size: 15, color: actionColor),
                      ),
                      const SizedBox(width: 14),
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
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '·  ${entry.performedBy}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${entry.target}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                              ),
                            ),
                            if (entry.reason != null && entry.reason!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Note: ${entry.reason}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                          fontWeight: FontWeight.w400,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final rowDividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    final items = [
      {'label': 'Campus Notices', 'value': '${stats.totalNotices}', 'icon': Icons.campaign_outlined},
      {'label': 'Total Posts Moderated', 'value': '${stats.totalPosts}', 'icon': Icons.article_outlined},
      {'label': 'Pending Flagged Content', 'value': '${stats.pendingReports}', 'icon': Icons.flag_outlined},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Platform Overview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Text(
                        item['value'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _buildActionButton(
            isDark: isDark,
            icon: Icons.download_rounded,
            label: 'Export Users Directory (CSV)',
            onTap: () {
              final csv = AdminService.generateUsersCsv();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Generated CSV export with ${csv.split("\n").length - 1} records.'),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ));
            },
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            isDark: isDark,
            icon: Icons.refresh_rounded,
            label: 'Refresh Platform Metrics',
            onTap: () {
              context.read<AdminDashboardProvider>().loadDashboard();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Dashboard statistics refreshed.'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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