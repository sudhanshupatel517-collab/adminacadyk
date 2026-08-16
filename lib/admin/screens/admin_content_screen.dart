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
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    final filtered = provider.content.where((c) {
      if (_statusFilter.isEmpty) return true;
      return c.status == _statusFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Filters
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
                    _buildFilterRow(isDark),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: AdminSearchBar(
                    hint: 'Search content...',
                    onChanged: (q) => provider.setSearch(q),
                  )),
                  const SizedBox(width: 16),
                  _buildFilterRow(isDark),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Content List
          if (provider.isLoading)
            Center(child: Padding(
              padding: const EdgeInsets.all(60),
              child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            ))
          else if (filtered.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
                  const SizedBox(height: 12),
                  Text('No content found.', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
                ],
              ),
            ))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Desktop: Table layout
                if (constraints.maxWidth >= AdminBreakpoints.mobile) {
                  return _buildDesktopTable(filtered, isDark, isEditor, cardBg, borderColor);
                }
                // Mobile: Card layout
                return _buildMobileCards(filtered, isDark, isEditor);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    final filters = [
      {'key': '', 'label': 'All'},
      {'key': 'published', 'label': 'Published'},
      {'key': 'flagged', 'label': 'Flagged'},
      {'key': 'removed', 'label': 'Removed'},
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: filters.map((f) {
        final isActive = _statusFilter == f['key'];
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _statusFilter = f['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                      : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? Colors.transparent : (isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
                ),
                child: Text(f['label']!, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isActive
                      ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
                      : (isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
                )),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // â”€â”€ DESKTOP TABLE â”€â”€
  Widget _buildDesktopTable(List<ManagedContent> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Author', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 4, child: Text('Content', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 1, child: Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
                Expanded(flex: 1, child: Center(child: Text('Engagement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
                if (isEditor) Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((item) {
            final statusColor = item.status == 'published'
                ? const Color(0xFF00BA7C)
                : item.status == 'flagged'
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF5350);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                            child: Text(item.authorName[0].toUpperCase(), style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            )),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item.authorName, style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ), overflow: TextOverflow.ellipsis)),
                        ],
                      )),
                      Expanded(flex: 4, child: Text(
                        item.content.length > 80 ? '${item.content.substring(0, 80)}...' : item.content,
                        style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
                        overflow: TextOverflow.ellipsis, maxLines: 2,
                      )),
                      Expanded(flex: 1, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.postType, style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                        ), overflow: TextOverflow.ellipsis),
                      )),
                      Expanded(flex: 1, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.status.toUpperCase(), style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, color: statusColor,
                        ), overflow: TextOverflow.ellipsis),
                      )),
                      Expanded(flex: 1, child: Center(child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_rounded, size: 12, color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC)),
                          const SizedBox(width: 3),
                          Text('${item.likeCount}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555))),
                          if (item.reportCount > 0) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.flag_rounded, size: 12, color: const Color(0xFFEF5350)),
                            const SizedBox(width: 3),
                            Text('${item.reportCount}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF5350))),
                          ],
                        ],
                      ))),
                      if (isEditor)
                        Expanded(flex: 2, child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (item.status == 'flagged')
                              _buildActionBtn(isDark, Icons.check_circle_outline_rounded, 'Approve', () {
                                context.read<AdminContentProvider>().updateContentStatus(item.id, 'published');
                              }),
                            if (item.status == 'flagged') const SizedBox(width: 6),
                            if (item.status != 'removed')
                              _buildActionBtn(isDark, Icons.delete_outline_rounded, 'Remove', () {
                                context.read<AdminContentProvider>().updateContentStatus(item.id, 'removed');
                              }, danger: true),
                          ],
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

  Widget _buildActionBtn(bool isDark, IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? const Color(0xFFEF5350) : const Color(0xFF00BA7C);
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  // â”€â”€ MOBILE CARDS â”€â”€
  Widget _buildMobileCards(List<ManagedContent> items, bool isDark, bool isEditor) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final statusColor = item.status == 'published'
            ? const Color(0xFF00BA7C)
            : item.status == 'flagged'
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF5350);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                    child: Text(item.authorName[0].toUpperCase(), style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.authorName, style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      )),
                      Text(item.postType, style: TextStyle(
                        fontSize: 11, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                      )),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item.status.toUpperCase(), style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: statusColor,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.content, style: TextStyle(
                fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
              ), maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite_rounded, size: 14, color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC)),
                  const SizedBox(width: 4),
                  Text('${item.likeCount}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
                  const SizedBox(width: 12),
                  Icon(Icons.comment_rounded, size: 14, color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC)),
                  const SizedBox(width: 4),
                  Text('${item.commentCount}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
                  if (item.reportCount > 0) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.flag_rounded, size: 14, color: Color(0xFFEF5350)),
                    const SizedBox(width: 4),
                    Text('${item.reportCount}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF5350))),
                  ],
                ],
              ),
              if (isEditor && item.status != 'removed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.status == 'flagged')
                      Expanded(child: OutlinedButton(
                        onPressed: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'published'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00BA7C),
                          side: const BorderSide(color: Color(0xFF00BA7C)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      )),
                    if (item.status == 'flagged') const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(
                      onPressed: () => context.read<AdminContentProvider>().updateContentStatus(item.id, 'removed'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF5350),
                        side: const BorderSide(color: Color(0xFFEF5350)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Remove', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    )),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}