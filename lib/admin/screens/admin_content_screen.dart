import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_content_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminContentProvider>().loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminContentProvider>();
    final isEditor = context.watch<AdminAuthProvider>().isEditor;
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    final filtered = provider.content.where((c) {
      if (_statusFilter == 'all' || _statusFilter.isEmpty) return true;
      return c.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          const AdminSectionHeader(
            title: 'Content Moderation',
            padding: EdgeInsets.only(bottom: 16),
          ),

          // Search & Filter Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    AdminSearchBar(
                      hint: 'Search content...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AdminFilterChips(
                        filters: const ['all', 'published', 'flagged', 'removed'],
                        selected: _statusFilter,
                        onSelected: (f) => setState(() => _statusFilter = f),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      hint: 'Search posts by text or student author...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                  ),
                  const SizedBox(width: 14),
                  AdminFilterChips(
                    filters: const ['all', 'published', 'flagged', 'removed'],
                    selected: _statusFilter,
                    onSelected: (f) => setState(() => _statusFilter = f),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Content Moderation Table
          if (provider.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.text(isDark)),
                ),
              ),
            )
          else if (filtered.isEmpty)
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
                  'No student content items match the filter.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSec(isDark)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= AdminBreakpoints.mobile) {
                  return _buildDesktopTable(filtered, isDark, isEditor, cardBg, borderColor);
                }
                return _buildMobileCards(filtered, isDark, isEditor);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<ManagedContent> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
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
                Expanded(flex: 2, child: Text('AUTHOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 4, child: Text('POST CONTENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Center(child: Text('ENGAGEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
                if (isEditor)
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((item) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: AppColors.surfaceAlt(isDark),
                              child: Text(
                                item.authorName.isNotEmpty ? item.authorName[0].toUpperCase() : 'U',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.text(isDark)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.authorName,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(isDark)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          item.content.length > 90 ? '${item.content.substring(0, 90)}...' : item.content,
                          style: TextStyle(fontSize: 12.5, color: AppColors.text(isDark)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.postType.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSec(isDark)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AdminStatusBadge(status: item.status),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            '${item.likeCount} likes · ${item.reportCount} reports',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: item.reportCount > 0 ? AppColors.error : AppColors.textSec(isDark),
                              fontWeight: item.reportCount > 0 ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      if (isEditor)
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (item.status == 'flagged') ...[
                                _buildTextActionBtn(
                                  label: 'Approve',
                                  onTap: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'published'),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (item.status != 'removed')
                                _buildTextActionBtn(
                                  label: 'Remove',
                                  onTap: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'removed'),
                                  isDanger: true,
                                  isDark: isDark,
                                ),
                            ],
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

  Widget _buildMobileCards(List<ManagedContent> items, bool isDark, bool isEditor) {
    final borderColor = AppColors.border(isDark);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
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
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.surfaceAlt(isDark),
                    child: Text(item.authorName.isNotEmpty ? item.authorName[0].toUpperCase() : 'U', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text(isDark))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.authorName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(isDark)),
                    ),
                  ),
                  AdminStatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.content,
                style: TextStyle(fontSize: 12.5, color: AppColors.text(isDark)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${item.likeCount} likes · ${item.commentCount} comments · ${item.reportCount} reports',
                style: TextStyle(
                  fontSize: 11.5,
                  color: item.reportCount > 0 ? AppColors.error : AppColors.textSec(isDark),
                  fontWeight: item.reportCount > 0 ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (isEditor && item.status != 'removed') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (item.status == 'flagged')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'published'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: Color(0xFFBBF7D0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (item.status == 'flagged') const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'removed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: isDark ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text('Remove', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextActionBtn({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isDanger = false,
  }) {
    final borderColor = AppColors.border(isDark);
    final textColor = isDanger ? AppColors.error : AppColors.textSec(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}