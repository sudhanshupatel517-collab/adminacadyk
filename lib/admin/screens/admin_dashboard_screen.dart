import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_responsive.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ValueChanged<String>? onNavigate;
  const AdminDashboardScreen({super.key, this.onNavigate});

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
      return Center(child: CircularProgressIndicator(
        strokeWidth: 2,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ));
    }

    if (provider.state == LoadState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            Text(provider.error ?? 'Unable to load dashboard', style: TextStyle(
              color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
            )),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => provider.loadDashboard(),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
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
              // Stat Cards Grid
              _buildStatGrid(stats, isDark, constraints.maxWidth),
              const SizedBox(height: 24),

              // Content Area
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildRecentActivity(isDark, provider)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: Column(
                      children: [
                        _buildPlatformOverview(isDark, stats),
                        const SizedBox(height: 20),
                        _buildQuickActions(isDark),
                      ],
                    )),
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
    final cards = [
      AdminStatCard(
        title: 'Total Users', value: '${stats.totalUsers}',
        icon: Icons.people_alt_rounded,
        iconColor: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0),
        subtitle: '+${stats.newUsersToday} today',
        onTap: () => widget.onNavigate?.call('users'),
      ),
      AdminStatCard(
        title: 'Active Users', value: '${stats.activeUsers}',
        icon: Icons.person_rounded,
        iconColor: const Color(0xFF00BA7C),
        subtitle: '${((stats.activeUsers / stats.totalUsers) * 100).toStringAsFixed(0)}%',
        onTap: () => widget.onNavigate?.call('users'),
      ),
      AdminStatCard(
        title: 'Total Posts', value: '${stats.totalPosts}',
        icon: Icons.description_rounded,
        iconColor: isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
        onTap: () => widget.onNavigate?.call('content'),
      ),
      AdminStatCard(
        title: 'Pending Reports', value: '${stats.pendingReports}',
        icon: Icons.flag_rounded,
        iconColor: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
        onTap: () => widget.onNavigate?.call('content'),
      ),
    ];

    int crossAxisCount;
    double childAspectRatio;

    if (width >= AdminBreakpoints.tablet) {
      crossAxisCount = 4;
      childAspectRatio = 1.5;
    } else if (width >= AdminBreakpoints.mobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.7;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildRecentActivity(bool isDark, AdminDashboardProvider provider) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('Live', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.recentActivity.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No recent activity', style: TextStyle(
                color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA), fontSize: 13,
              ))),
            )
          else
            ...provider.recentActivity.map((entry) {
              IconData actionIcon;
              Color actionColor;
              switch (entry.action.toLowerCase()) {
                case 'user suspended':
                  actionIcon = Icons.block_rounded;
                  actionColor = const Color(0xFFF59E0B);
                  break;
                case 'content flagged':
                  actionIcon = Icons.flag_rounded;
                  actionColor = const Color(0xFFEF5350);
                  break;
                case 'content removed':
                  actionIcon = Icons.delete_rounded;
                  actionColor = const Color(0xFFEF5350);
                  break;
                case 'new admin added':
                  actionIcon = Icons.person_add_rounded;
                  actionColor = const Color(0xFF00BA7C);
                  break;
                default:
                  actionIcon = Icons.info_outline_rounded;
                  actionColor = isDark ? const Color(0xFF888888) : const Color(0xFF999999);
              }

              return InkWell(
                onTap: () {
                  if (entry.action.toLowerCase().contains('user')) {
                    widget.onNavigate?.call('users');
                  } else if (entry.action.toLowerCase().contains('content')) {
                    widget.onNavigate?.call('content');
                  } else if (entry.action.toLowerCase().contains('setting')) {
                    widget.onNavigate?.call('settings');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(actionIcon, size: 16, color: actionColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.action, style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            )),
                            const SizedBox(height: 2),
                            Text('${entry.performedBy} -> ${entry.target}', style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF666666) : const Color(0xFF888888),
                            )),
                          ],
                        ),
                      ),
                      Text(_timeAgo(entry.timestamp), style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF444444) : const Color(0xFFAAAAAA),
                      )),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlatformOverview(bool isDark, dynamic stats) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    final items = [
      {'label': 'Opportunities', 'value': '${stats.totalOpportunities}', 'icon': Icons.work_rounded, 'color': isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0), 'route': 'content'},
      {'label': 'Clubs', 'value': '${stats.totalClubs}', 'icon': Icons.groups_rounded, 'color': isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2), 'route': 'content'},
      {'label': 'Events', 'value': '${stats.totalEvents}', 'icon': Icons.event_rounded, 'color': isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32), 'route': 'content'},
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
          Text('Platform Overview', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          )),
          const SizedBox(height: 20),
          ...items.map((item) => InkWell(
            onTap: () => widget.onNavigate?.call(item['route'] as String),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item['icon'] as IconData, size: 18, color: item['color'] as Color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(item['label'] as String, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                  ))),
                  Text(item['value'] as String, style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  )),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

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
          Text('Quick Actions', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          )),
          const SizedBox(height: 16),
          _buildActionButton(isDark, Icons.person_add_rounded, 'Add New User', () {
            widget.onNavigate?.call('users');
          }),
          const SizedBox(height: 8),
          _buildActionButton(isDark, Icons.shield_rounded, 'Review Reports', () {
            widget.onNavigate?.call('content');
          }),
          const SizedBox(height: 8),
          _buildActionButton(isDark, Icons.download_rounded, 'Export Data', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exporting campus records to CSV...')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark, IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
              )),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}