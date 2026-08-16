import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_responsive.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminDashboardProvider>();
      if (provider.recentActivity.isEmpty) provider.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminDashboardProvider>();
    final entries = provider.recentActivity;

    if (provider.state == LoadState.loading) {
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF1A1A1A)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Activity Log', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              )),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => provider.loadDashboard(),
                icon: Icon(Icons.refresh_rounded, size: 16, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)),
                label: Text('Refresh', style: TextStyle(color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555))),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (entries.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 48, color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
                  const SizedBox(height: 12),
                  Text('No activity recorded yet.', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
                ],
              ),
            ))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;

                if (isDesktop) {
                  // DESKTOP: Table-like horizontal rows
                  return _buildDesktopTable(entries, isDark);
                } else {
                  // MOBILE: Vertical cards
                  return _buildMobileCards(entries, isDark);
                }
              },
            ),
        ],
      ),
    );
  }

  // â”€â”€ DESKTOP: Horizontal table rows â”€â”€
  Widget _buildDesktopTable(List<ActivityLogEntry> entries, bool isDark) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    final headerBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9);
    final headerText = isDark ? const Color(0xFF888888) : const Color(0xFF888888);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText))),
                Expanded(flex: 3, child: Text('Action', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 2, child: Text('Performed By', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 3, child: Text('Target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          // Data rows
          ...entries.map((item) {
            final iconInfo = _getActionIcon(item.action, isDark);
            String timeAgo;
            try { timeAgo = timeago.format(item.timestamp); } catch (_) { timeAgo = 'recently'; }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: iconInfo.color.withValues(alpha: isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(iconInfo.icon, size: 16, color: iconInfo.color),
                      )),
                      Expanded(flex: 3, child: Text(item.action, style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ))),
                      Expanded(flex: 2, child: Text(item.performedBy, style: TextStyle(
                        fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                      ))),
                      Expanded(flex: 3, child: Text(item.target, style: TextStyle(
                        fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
                      ), overflow: TextOverflow.ellipsis)),
                      Expanded(flex: 2, child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(timeAgo, style: TextStyle(
                          fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFFAAAAAA),
                        )),
                      )),
                    ],
                  ),
                ),
                Container(height: 1, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }

  // â”€â”€ MOBILE: Vertical cards â”€â”€
  Widget _buildMobileCards(List<ActivityLogEntry> entries, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = entries[index];
        final iconInfo = _getActionIcon(item.action, isDark);
        String timeAgo;
        try { timeAgo = timeago.format(item.timestamp); } catch (_) { timeAgo = 'recently'; }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconInfo.color.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconInfo.icon, size: 18, color: iconInfo.color),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.action, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  )),
                  const SizedBox(height: 4),
                  Text('by ${item.performedBy}', style: TextStyle(
                    fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                  )),
                  Text(item.target, style: TextStyle(
                    fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
                  )),
                  const SizedBox(height: 6),
                  Text(timeAgo, style: TextStyle(
                    fontSize: 11, color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
                  )),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  _ActionIconInfo _getActionIcon(String action, bool isDark) {
    switch (action.toLowerCase()) {
      case 'user suspended':
        return _ActionIconInfo(Icons.block_rounded, const Color(0xFFF59E0B));
      case 'content flagged':
        return _ActionIconInfo(Icons.flag_rounded, const Color(0xFFEF5350));
      case 'content removed':
        return _ActionIconInfo(Icons.delete_rounded, const Color(0xFFEF5350));
      case 'settings updated':
        return _ActionIconInfo(Icons.settings_rounded, isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0));
      case 'user role changed':
        return _ActionIconInfo(Icons.admin_panel_settings_rounded, isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2));
      case 'new admin added':
        return _ActionIconInfo(Icons.person_add_rounded, const Color(0xFF00BA7C));
      default:
        return _ActionIconInfo(Icons.info_outline_rounded, isDark ? const Color(0xFF888888) : const Color(0xFF999999));
    }
  }
}

class _ActionIconInfo {
  final IconData icon;
  final Color color;
  _ActionIconInfo(this.icon, this.color);
}