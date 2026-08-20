import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  String _categoryFilter = 'all';

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
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    final entries = provider.recentActivity.where((entry) {
      if (_categoryFilter == 'all') return true;
      if (_categoryFilter == 'users') return entry.action.toLowerCase().contains('user') || entry.action.toLowerCase().contains('account');
      if (_categoryFilter == 'content') return entry.action.toLowerCase().contains('post') || entry.action.toLowerCase().contains('content') || entry.action.toLowerCase().contains('moderat');
      if (_categoryFilter == 'events') return entry.action.toLowerCase().contains('event') || entry.action.toLowerCase().contains('notice');
      return true;
    }).toList();

    if (provider.state == LoadState.loading) {
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
          AdminSectionHeader(
            title: 'System Activity & Audit Trail',
            padding: const EdgeInsets.only(bottom: 16),
            trailing: OutlinedButton(
              onPressed: () => provider.loadDashboard(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Refresh Log'),
            ),
          ),

          // Header & Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AdminFilterChips(
              filters: const ['all', 'users', 'content', 'events'],
              selected: _categoryFilter,
              onSelected: (f) => setState(() => _categoryFilter = f),
            ),
          ),
          const SizedBox(height: 16),

          if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: Text(
                  'No audit logs match the current filter criteria.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSec(isDark)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;
                if (isDesktop) {
                  return _buildDesktopTable(entries, isDark, cardBg, borderColor);
                } else {
                  return _buildMobileCards(entries, isDark, borderColor);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<ActivityLogEntry> entries, bool isDark, Color cardBg, Color borderColor) {
    final headerBg = AppColors.surfaceAlt(isDark);
    final headerText = AppColors.textSec(isDark);
    final rowDivider = AppColors.borderSubtle(isDark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('ACTION DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('PERFORMED BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 3, child: Text('TARGET RESOURCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('TIMESTAMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...entries.map((item) {
            String timeAgo;
            try {
              timeAgo = timeago.format(item.timestamp);
            } catch (_) {
              timeAgo = 'recently';
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.action,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.performedBy,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSec(isDark),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.target,
                              style: TextStyle(fontSize: 12.5, color: AppColors.text(isDark)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.reason != null && item.reason!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.reason!,
                                style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark), fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMut(isDark),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: rowDivider),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileCards(List<ActivityLogEntry> entries, bool isDark, Color borderColor) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = entries[index];
        String timeAgo;
        try {
          timeAgo = timeago.format(item.timestamp);
        } catch (_) {
          timeAgo = 'recently';
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.action,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(isDark)),
                    ),
                  ),
                  Text(timeAgo, style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark))),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Performed by: ${item.performedBy}',
                style: TextStyle(fontSize: 12, color: AppColors.textSec(isDark)),
              ),
              const SizedBox(height: 2),
              Text(
                'Target: ${item.target}',
                style: TextStyle(fontSize: 12, color: AppColors.textMut(isDark)),
              ),
            ],
          ),
        );
      },
    );
  }
}