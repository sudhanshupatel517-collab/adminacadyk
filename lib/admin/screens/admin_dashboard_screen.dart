import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_responsive.dart';
import '../data/admin_models.dart';

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
    final cardBg = isDark ? const Color(0xFF13171F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    if (provider.state == LoadState.loading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0A66C2),
        ),
      );
    }

    if (provider.state == LoadState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 36, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(provider.error ?? 'Failed to load dashboard metrics.', style: TextStyle(color: textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => provider.loadDashboard(),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = provider.stats ?? DashboardStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Metric Row
              _buildMetricGrid(stats, constraints.maxWidth),
              const SizedBox(height: 20),

              // Main Content Layout
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildRecentActivitySection(isDark, cardBg, borderColor, textPrimary, textSecondary, provider.recentActivity),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildSystemHealthCard(isDark, cardBg, borderColor, textPrimary, textSecondary, stats),
                          const SizedBox(height: 20),
                          _buildInstitutionalBreakdownCard(isDark, cardBg, borderColor, textPrimary, textSecondary),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRecentActivitySection(isDark, cardBg, borderColor, textPrimary, textSecondary, provider.recentActivity),
                    const SizedBox(height: 20),
                    _buildSystemHealthCard(isDark, cardBg, borderColor, textPrimary, textSecondary, stats),
                    const SizedBox(height: 20),
                    _buildInstitutionalBreakdownCard(isDark, cardBg, borderColor, textPrimary, textSecondary),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricGrid(DashboardStats stats, double maxWidth) {
    int crossAxisCount = 4;
    if (maxWidth < 640) {
      crossAxisCount = 2;
    } else if (maxWidth < 960) {
      crossAxisCount = 2;
    }

    final cards = [
      AdminStatCard(
        label: 'Total Registered',
        value: '${stats.totalUsers}',
        subtitle: '${stats.activeUsers} active accounts',
        icon: Icons.people_outline_rounded,
        accentColor: const Color(0xFF0A66C2),
      ),
      AdminStatCard(
        label: 'Active Content',
        value: '${stats.totalPosts}',
        subtitle: '${stats.totalOpportunities} career opportunities',
        icon: Icons.article_outlined,
        accentColor: const Color(0xFF059669),
      ),
      AdminStatCard(
        label: 'Campus Clubs',
        value: '${stats.totalClubs}',
        subtitle: '${stats.totalEvents} scheduled events',
        icon: Icons.groups_outlined,
        accentColor: const Color(0xFF7C3AED),
      ),
      AdminStatCard(
        label: 'Pending Moderation',
        value: '${stats.pendingReports}',
        subtitle: stats.pendingReports > 0 ? 'Requires administrative review' : 'Queue is clear',
        icon: Icons.flag_outlined,
        accentColor: stats.pendingReports > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
      ),
    ];

    if (crossAxisCount == 4) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: cards,
    );
  }

  Widget _buildRecentActivitySection(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    List<ActivityLogEntry> activities,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent System Audit Log',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                'Latest entries',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No recent activities logged.', style: TextStyle(fontSize: 13, color: textSecondary)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) => Divider(color: borderColor, height: 16),
              itemBuilder: (context, index) {
                final a = activities[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCategoryColor(a.category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a.action,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              Text(
                                _formatTimeAgo(a.timestamp),
                                style: TextStyle(fontSize: 11, color: textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${a.performedBy} -> ${a.target}',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    DashboardStats stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 16),
          _buildHealthRow('Authentication & SSO', 'Active', const Color(0xFF059669), textPrimary, textSecondary),
          Divider(color: borderColor, height: 16),
          _buildHealthRow('Database Services', 'Synced', const Color(0xFF059669), textPrimary, textSecondary),
          Divider(color: borderColor, height: 16),
          _buildHealthRow('Real-time Messaging', 'Connected', const Color(0xFF059669), textPrimary, textSecondary),
          Divider(color: borderColor, height: 16),
          _buildHealthRow('Content Storage', '94% Available', const Color(0xFF0A66C2), textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String service, String status, Color statusColor, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(service, style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
            const SizedBox(width: 6),
            Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildInstitutionalBreakdownCard(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Department Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 16),
          _buildDeptProgress('Computer Science & Eng.', 0.45, textPrimary, textSecondary),
          const SizedBox(height: 10),
          _buildDeptProgress('Information Technology', 0.25, textPrimary, textSecondary),
          const SizedBox(height: 10),
          _buildDeptProgress('Electronics & Comm.', 0.18, textPrimary, textSecondary),
          const SizedBox(height: 10),
          _buildDeptProgress('Mechanical & Civil', 0.12, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildDeptProgress(String name, double pct, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500)),
            Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: textSecondary.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'user':
        return const Color(0xFF0A66C2);
      case 'content':
        return const Color(0xFFDC2626);
      case 'settings':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF059669);
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}