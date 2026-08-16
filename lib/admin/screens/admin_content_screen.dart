import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/admin_models.dart';
import '../providers/admin_content_provider.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminContentProvider>().loadContent();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminContentProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Content Moderation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review flagged posts, manage academic announcements, and enforce community standards',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),

          // Filters Bar
          _buildFiltersBar(isDark, provider),
          const SizedBox(height: 16),

          // Content List
          if (provider.state == ContentLoadState.loading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            )
          else if (provider.content.isEmpty)
            _buildEmptyState(isDark)
          else
            _buildContentTable(context, isDark, provider),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(bool isDark, AdminContentProvider provider) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearch(val),
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: 'Search content or author...',
                hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA)),
                prefixIcon: Icon(Icons.search_rounded, size: 18, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButton<String>(
                value: provider.statusFilter ?? 'all',
                dropdownColor: cardBg,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Content')),
                  DropdownMenuItem(value: 'flagged', child: Text('Flagged / Reported')),
                  DropdownMenuItem(value: 'published', child: Text('Published')),
                  DropdownMenuItem(value: 'removed', child: Text('Removed')),
                ],
                onChanged: (val) => provider.setStatusFilter(val),
              ),
            ),
          ),
          Text(
            '${provider.content.length} entries',
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 48, color: isDark ? const Color(0xFF00BA7C) : const Color(0xFF2E7D32)),
          const SizedBox(height: 12),
          Text(
            'Moderation Queue Clear',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          Text('No content matches your filter criteria.', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF666666) : const Color(0xFF888888))),
        ],
      ),
    );
  }

  Widget _buildContentTable(BuildContext context, bool isDark, AdminContentProvider provider) {
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 24,
            headingRowColor: WidgetStateProperty.all(
              isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F8),
            ),
            columns: [
              _buildHeaderCell('Author', isDark),
              _buildHeaderCell('Preview', isDark),
              _buildHeaderCell('Type', isDark),
              _buildHeaderCell('Status', isDark),
              _buildHeaderCell('Reports', isDark),
              _buildHeaderCell('Actions', isDark),
            ],
            rows: provider.content.map((item) {
              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.authorName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                        Text(item.authorEmail, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF666666) : const Color(0xFF888888))),
                      ],
                    ),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        item.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444)),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.postType.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.status == 'published'
                            ? const Color(0xFF00BA7C).withValues(alpha: 0.12)
                            : (item.status == 'flagged'
                                ? const Color(0xFFEF5350).withValues(alpha: 0.12)
                                : const Color(0xFF888888).withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: item.status == 'published'
                              ? const Color(0xFF00BA7C)
                              : (item.status == 'flagged' ? const Color(0xFFEF5350) : const Color(0xFF888888)),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${item.reportCount}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: item.reportCount > 0 ? const Color(0xFFEF5350) : (isDark ? const Color(0xFF666666) : const Color(0xFF888888)),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View Full Post
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          tooltip: 'Review Full Post',
                          onPressed: () => _showPostModal(context, item, isDark),
                        ),
                        // Quick Approve
                        if (item.status != 'published')
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF00BA7C)),
                            tooltip: 'Approve & Publish',
                            onPressed: () async {
                              final ok = await provider.updateStatus(item.id, 'published');
                              if (context.mounted && ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Content approved and published.')),
                                );
                              }
                            },
                          ),
                        // Quick Flag
                        if (item.status != 'flagged')
                          IconButton(
                            icon: const Icon(Icons.flag_outlined, size: 16, color: Color(0xFFF59E0B)),
                            tooltip: 'Flag Content',
                            onPressed: () async {
                              final ok = await provider.updateStatus(item.id, 'flagged');
                              if (context.mounted && ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Content flagged for review.')),
                                );
                              }
                            },
                          ),
                        // Delete
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF5350)),
                          tooltip: 'Delete Post',
                          onPressed: () => _showDeleteModal(context, item, isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _buildHeaderCell(String label, bool isDark) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showPostModal(BuildContext context, ManagedContent item, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Post Inspection (${item.id})', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                    child: Text(item.authorName[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Text(item.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 6),
                  Text('(${item.authorEmail})', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF888888))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.content,
                  style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('❤️ ${item.likeCount} Likes', style: const TextStyle(fontSize: 12)),
                  Text('💬 ${item.commentCount} Comments', style: const TextStyle(fontSize: 12)),
                  Text('🚩 ${item.reportCount} Reports', style: const TextStyle(fontSize: 12, color: Color(0xFFEF5350))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (item.status != 'published')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BA7C), foregroundColor: Colors.white),
              onPressed: () async {
                await context.read<AdminContentProvider>().updateStatus(item.id, 'published');
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Approve & Publish'),
            ),
          if (item.status != 'removed')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white),
              onPressed: () async {
                await context.read<AdminContentProvider>().updateStatus(item.id, 'removed');
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Remove Post'),
            ),
        ],
      ),
    );
  }

  void _showDeleteModal(BuildContext context, ManagedContent item, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Post', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF5350))),
        content: const Text('Are you sure you want to permanently delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white),
            onPressed: () async {
              await context.read<AdminContentProvider>().deleteContent(item.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}