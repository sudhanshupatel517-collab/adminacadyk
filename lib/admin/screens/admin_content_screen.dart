import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_content_provider.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_responsive.dart';
import '../data/admin_models.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminContentProvider>().loadContent();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminContentProvider>();
    final cardBg = isDark ? const Color(0xFF13171F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter / Search Toolbar
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    AdminSearchBar(
                      controller: _searchCtrl,
                      hint: 'Search content by keyword or author...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterRow(provider, isDark),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      controller: _searchCtrl,
                      hint: 'Search moderation queue by keyword or author...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildFilterRow(provider, isDark),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Content Table / List
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: provider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : provider.content.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: AdminEmptyState(
                          icon: Icons.shield_outlined,
                          title: 'No content found',
                          subtitle: 'All reported and active content has been reviewed.',
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < AdminBreakpoints.mobile) {
                            return _buildMobileContentList(provider.content, isDark, borderColor, textPrimary, textSecondary);
                          }
                          return _buildDesktopContentTable(provider.content, isDark, borderColor, textPrimary, textSecondary);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AdminContentProvider provider, bool isDark) {
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFD1D5DB);
    final bg = isDark ? const Color(0xFF13171F) : Colors.white;
    final text = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.statusFilter,
          style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w500),
          dropdownColor: bg,
          icon: Icon(Icons.arrow_drop_down_rounded, size: 18, color: text),
          onChanged: (v) => provider.setStatusFilter(v ?? ''),
          items: const [
            DropdownMenuItem(value: '', child: Text('All Content')),
            DropdownMenuItem(value: 'flagged', child: Text('Flagged / Reported')),
            DropdownMenuItem(value: 'published', child: Text('Published')),
            DropdownMenuItem(value: 'removed', child: Text('Removed')),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopContentTable(
    List<ManagedContent> items,
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.8),
        1: FlexColumnWidth(3.0),
        2: FlexColumnWidth(1.0),
        3: FlexColumnWidth(1.0),
        4: FlexColumnWidth(1.4),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : const Color(0xFFF9FAFB),
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          children: [
            _buildTableHeader('AUTHOR', isDark),
            _buildTableHeader('CONTENT PREVIEW', isDark),
            _buildTableHeader('TYPE', isDark),
            _buildTableHeader('STATUS', isDark),
            _buildTableHeader('ACTIONS', isDark, alignRight: true),
          ],
        ),
        ...items.map((c) {
          return TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor.withOpacity(0.6))),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.authorName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                    Text(c.authorEmail, style: TextStyle(fontSize: 11, color: textSecondary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  c.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(c.postType.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildStatusBadge(c.status, c.reportCount),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      tooltip: 'View Full Post',
                      onPressed: () => _showContentDetailDialog(context, c),
                    ),
                    if (c.status != 'published')
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF059669)),
                        tooltip: 'Approve & Publish',
                        onPressed: () => context.read<AdminContentProvider>().updateContentStatus(c.id, 'published'),
                      ),
                    if (c.status != 'flagged')
                      IconButton(
                        icon: const Icon(Icons.flag_outlined, size: 16, color: Color(0xFFD97706)),
                        tooltip: 'Flag Content',
                        onPressed: () => context.read<AdminContentProvider>().updateContentStatus(c.id, 'flagged'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                      tooltip: 'Delete Post',
                      onPressed: () => _showDeleteConfirmDialog(context, c),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMobileContentList(
    List<ManagedContent> items,
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
      itemBuilder: (context, index) {
        final c = items[index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(c.authorName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  _buildStatusBadge(c.status, c.reportCount),
                ],
              ),
              const SizedBox(height: 6),
              Text(c.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: textPrimary)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${c.postType.toUpperCase()} · ${c.likeCount} likes', style: TextStyle(fontSize: 11, color: textSecondary)),
                  Row(
                    children: [
                      TextButton(onPressed: () => _showContentDetailDialog(context, c), child: const Text('View', style: TextStyle(fontSize: 12))),
                      if (c.status != 'published')
                        TextButton(
                          onPressed: () => context.read<AdminContentProvider>().updateContentStatus(c.id, 'published'),
                          child: const Text('Approve', style: TextStyle(fontSize: 12, color: Color(0xFF059669))),
                        ),
                      TextButton(
                        onPressed: () => _showDeleteConfirmDialog(context, c),
                        child: const Text('Delete', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String title, bool isDark, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, int reportCount) {
    Color bg;
    Color text;
    String label = status.toUpperCase();

    if (status == 'published') {
      bg = const Color(0xFF059669).withOpacity(0.12);
      text = const Color(0xFF059669);
    } else if (status == 'flagged') {
      bg = const Color(0xFFDC2626).withOpacity(0.12);
      text = const Color(0xFFDC2626);
      if (reportCount > 0) label = 'FLAGGED ($reportCount)';
    } else {
      bg = const Color(0xFF6B7280).withOpacity(0.12);
      text = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
    );
  }

  void _showContentDetailDialog(BuildContext context, ManagedContent content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Post Review (${content.id})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            _buildStatusBadge(content.status, content.reportCount),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Author: ${content.authorName} (${content.authorEmail})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Category: ${content.postType.toUpperCase()} · Engagement: ${content.likeCount} likes, ${content.commentCount} comments', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(content.content, style: const TextStyle(fontSize: 13, height: 1.4)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (content.status != 'published')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: () {
                context.read<AdminContentProvider>().updateContentStatus(content.id, 'published');
                Navigator.pop(ctx);
              },
              child: const Text('Approve & Publish'),
            ),
          if (content.status != 'removed')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () {
                context.read<AdminContentProvider>().updateContentStatus(content.id, 'removed');
                Navigator.pop(ctx);
              },
              child: const Text('Remove Content'),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ManagedContent content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to permanently delete this post by "${content.authorName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              await context.read<AdminContentProvider>().deleteContent(content.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}