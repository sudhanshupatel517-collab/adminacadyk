import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_content_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  String _statusFilter = '';

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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final filtered = provider.content.where((c) {
      if (_statusFilter.isEmpty) return true;
      return c.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildFilterRow(isDark)),
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
                  const SizedBox(width: 16),
                  _buildFilterRow(isDark),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Content Moderation Table
          if (provider.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            )
          else if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.article_outlined, size: 36, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(
                      'No student content items match the filter.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ],
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

  Widget _buildFilterRow(bool isDark) {
    final filters = [
      {'key': '', 'label': 'All Content'},
      {'key': 'published', 'label': 'Published'},
      {'key': 'flagged', 'label': 'Flagged'},
      {'key': 'removed', 'label': 'Removed'},
    ];
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: filters.map((f) {
        final isActive = _statusFilter == f['key'];
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _statusFilter = f['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isActive ? Colors.transparent : borderColor, width: 1),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTable(List<ManagedContent> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
    final headerBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final headerText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final rowDivider = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('AUTHOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 4, child: Text('POST CONTENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Center(child: Text('ENGAGEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
                if (isEditor)
                  Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((item) {
            final isPublished = item.status == 'published';
            final isFlagged = item.status == 'flagged';

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              child: Text(
                                item.authorName.isNotEmpty ? item.authorName[0].toUpperCase() : 'U',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.authorName,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A)),
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
                          style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Text(
                              item.postType.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPublished
                                  ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4))
                                  : isFlagged
                                      ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB))
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2)),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isPublished
                                    ? (isDark ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFBBF7D0))
                                    : isFlagged
                                        ? (isDark ? const Color(0xFFD97706).withValues(alpha: 0.3) : const Color(0xFFFDE68A))
                                        : (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.3) : const Color(0xFFFECACA)),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isPublished
                                    ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                                    : isFlagged
                                        ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                                        : (isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.thumb_up_alt_outlined, size: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                              const SizedBox(width: 3),
                              Text('${item.likeCount}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                              if (item.reportCount > 0) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.flag_outlined, size: 12, color: Color(0xFFDC2626)),
                                const SizedBox(width: 3),
                                Text('${item.reportCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (isEditor)
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (item.status == 'flagged') ...[
                                _buildActionBtn(
                                  isDark: isDark,
                                  icon: Icons.check_circle_outline_rounded,
                                  label: 'Approve Post',
                                  onTap: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'published'),
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (item.status != 'removed')
                                _buildActionBtn(
                                  isDark: isDark,
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Remove Post',
                                  onTap: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'removed'),
                                  isDanger: true,
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
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isPublished = item.status == 'published';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    child: Text(item.authorName.isNotEmpty ? item.authorName[0].toUpperCase() : 'U', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.authorName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPublished ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4)) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2)),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isPublished ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
                    ),
                    child: Text(item.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPublished ? const Color(0xFF15803D) : const Color(0xFFB91C1C))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.content,
                style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text('${item.likeCount}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  const SizedBox(width: 10),
                  Icon(Icons.chat_bubble_outline_rounded, size: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text('${item.commentCount}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  if (item.reportCount > 0) ...[
                    const Spacer(),
                    Text('${item.reportCount} reports', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                  ],
                ],
              ),
              if (isEditor && item.status != 'removed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.status == 'flagged')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'published'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF16A34A),
                            side: const BorderSide(color: Color(0xFFBBF7D0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (item.status == 'flagged') const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'removed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildActionBtn({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final color = isDanger
        ? const Color(0xFFDC2626)
        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569));

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}