import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_notices_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});
  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNoticesProvider>().loadNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminNoticesProvider>();
    final isEditor = context.watch<AdminAuthProvider>().isEditor;
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    final filtered = provider.notices.where((n) {
      if (_statusFilter == 'all' || _statusFilter.isEmpty) return true;
      return n.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          AdminSectionHeader(
            title: 'Notices & Circulars',
            padding: const EdgeInsets.only(bottom: 16),
            trailing: isEditor
                ? ElevatedButton(
                    onPressed: _showCreateNoticeDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.brand,
                      foregroundColor: isDark ? AppColors.brand : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Create Notice'),
                  )
                : null,
          ),

          // Filter & Search Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    AdminSearchBar(hint: 'Search notices...', onChanged: (q) => provider.setSearch(q)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AdminFilterChips(
                        filters: const ['all', 'published', 'draft', 'archived'],
                        selected: _statusFilter,
                        onSelected: (f) => setState(() => _statusFilter = f),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: AdminSearchBar(hint: 'Search institutional notices and circulars...', onChanged: (q) => provider.setSearch(q))),
                  const SizedBox(width: 14),
                  AdminFilterChips(
                    filters: const ['all', 'published', 'draft', 'archived'],
                    selected: _statusFilter,
                    onSelected: (f) => setState(() => _statusFilter = f),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Content Area
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
                  'No notices match the selected filter.',
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

  Widget _buildDesktopTable(List<Notice> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
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
                Expanded(flex: 4, child: Text('CIRCULAR / NOTICE TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('PRIORITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('AUTHOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                if (isEditor)
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((notice) {
            final isUrgent = notice.priority.toLowerCase() == 'urgent';

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notice.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text(isDark),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (notice.content.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                notice.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMut(isDark),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUrgent
                                  ? (isDark ? AppColors.surfaceAlt(isDark) : AppColors.errorBg)
                                  : AppColors.surfaceAlt(isDark),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isUrgent
                                    ? (isDark ? AppColors.error.withValues(alpha: 0.3) : const Color(0xFFFECACA))
                                    : borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notice.priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isUrgent
                                    ? (isDark ? const Color(0xFFF87171) : AppColors.errorText)
                                    : AppColors.textSec(isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          notice.authorName ?? 'Administration',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSec(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AdminStatusBadge(status: notice.status),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMut(isDark),
                          ),
                        ),
                      ),
                      if (isEditor)
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildTextActionBtn(
                                label: 'Edit',
                                onTap: () => _showEditNoticeDialog(notice),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 6),
                              if (notice.status == 'draft') ...[
                                _buildTextActionBtn(
                                  label: 'Publish',
                                  onTap: () => context.read<AdminNoticesProvider>().publishNotice(notice.id),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                              ],
                              _buildTextActionBtn(
                                label: 'Delete',
                                onTap: () => _showDeleteDialog(notice),
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

  Widget _buildMobileCards(List<Notice> items, bool isDark, bool isEditor) {
    final borderColor = AppColors.border(isDark);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notice = items[index];
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
                      notice.title,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.text(isDark)),
                    ),
                  ),
                  AdminStatusBadge(status: notice.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                notice.content,
                style: TextStyle(fontSize: 12, color: AppColors.textSec(isDark)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Priority: ${notice.priority.toUpperCase()}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMut(isDark)),
                  ),
                  const Spacer(),
                  Text(
                    '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
                    style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark)),
                  ),
                ],
              ),
              if (isEditor) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showEditNoticeDialog(notice),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDeleteDialog(notice),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: isDark ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFFFCA5A5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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

  void _showCreateNoticeDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String priority = 'normal';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
          title: Text(
            'Create Institutional Notice',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(isDark, titleCtrl, 'Notice Title', required: true),
                const SizedBox(height: 12),
                _dialogField(isDark, contentCtrl, 'Notice Content / Announcement Body', maxLines: 4, required: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Normal', style: TextStyle(fontSize: 12))),
                        selected: priority == 'normal',
                        onSelected: (s) => setDialogState(() => priority = 'normal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Urgent', style: TextStyle(fontSize: 12))),
                        selected: priority == 'urgent',
                        onSelected: (s) => setDialogState(() => priority = 'urgent'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                context.read<AdminNoticesProvider>().createNotice(
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  priority: priority,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.brand,
                foregroundColor: isDark ? AppColors.brand : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoticeDialog(Notice notice) {
    final titleCtrl = TextEditingController(text: notice.title);
    final contentCtrl = TextEditingController(text: notice.content);
    String priority = notice.priority;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
          title: Text(
            'Edit Notice',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(isDark, titleCtrl, 'Notice Title', required: true),
                const SizedBox(height: 12),
                _dialogField(isDark, contentCtrl, 'Notice Content', maxLines: 4, required: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Normal', style: TextStyle(fontSize: 12))),
                        selected: priority == 'normal',
                        onSelected: (s) => setDialogState(() => priority = 'normal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Urgent', style: TextStyle(fontSize: 12))),
                        selected: priority == 'urgent',
                        onSelected: (s) => setDialogState(() => priority = 'urgent'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AdminNoticesProvider>().updateNotice(
                  notice.id,
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  priority: priority,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.brand,
                foregroundColor: isDark ? AppColors.brand : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Notice notice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
        title: Text(
          'Delete Notice',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
        ),
        content: Text(
          'Are you sure you want to delete "${notice.title}"?',
          style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminNoticesProvider>().deleteNotice(notice.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(bool isDark, TextEditingController ctrl, String label, {int maxLines = 1, bool required = false}) {
    final borderColor = AppColors.border(isDark);
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: TextStyle(fontSize: 12, color: AppColors.textMut(isDark)),
        filled: true,
        fillColor: AppColors.surfaceAlt(isDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.text(isDark), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}
