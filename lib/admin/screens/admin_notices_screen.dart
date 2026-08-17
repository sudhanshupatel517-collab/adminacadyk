import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_notices_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});
  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  String _statusFilter = '';

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
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    final filtered = provider.notices.where((n) {
      if (_statusFilter.isEmpty) return true;
      return n.status == _statusFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: AdminSearchBar(hint: 'Search notices...', onChanged: (q) => provider.setSearch(q))),
                        const SizedBox(width: 8),
                        _buildCreateButton(isDark, isEditor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChips(isDark),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: AdminSearchBar(hint: 'Search notices...', onChanged: (q) => provider.setSearch(q))),
                  const SizedBox(width: 16),
                  _buildFilterChips(isDark),
                  const SizedBox(width: 12),
                  _buildCreateButton(isDark, isEditor),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          if (provider.isLoading)
            Center(child: Padding(padding: const EdgeInsets.all(60), child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF1A1A1A))))
          else if (filtered.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(60), child: Column(children: [
              Icon(Icons.campaign_outlined, size: 48, color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
              const SizedBox(height: 12),
              Text('No notices found.', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
            ])))
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

  Widget _buildCreateButton(bool isDark, bool isEditor) {
    if (!isEditor) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showCreateNoticeDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: isDark ? const Color(0xFF1A1A1A) : Colors.white),
              const SizedBox(width: 6),
              Text('Create Notice', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF1A1A1A) : Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'key': '', 'label': 'All'},
      {'key': 'published', 'label': 'Published'},
      {'key': 'draft', 'label': 'Draft'},
      {'key': 'archived', 'label': 'Archived'},
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
                  color: isActive ? (isDark ? Colors.white : const Color(0xFF1A1A1A)) : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? Colors.transparent : (isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
                ),
                child: Text(f['label']!, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isActive ? (isDark ? const Color(0xFF1A1A1A) : Colors.white) : (isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
                )),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTable(List<Notice> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
    final headerBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9);
    final headerText = isDark ? const Color(0xFF888888) : const Color(0xFF888888);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(color: headerBg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
            child: Row(children: [
              Expanded(flex: 3, child: Text('Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 4, child: Text('Content', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Text('Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 2, child: Text('Author / Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              if (isEditor) Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
            ]),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((notice) {
            final priorityColor = notice.priority == 'urgent'
                ? const Color(0xFFEF5350)
                : notice.priority == 'important'
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF1E88E5);
            final statusColor = notice.status == 'published'
                ? const Color(0xFF00BA7C)
                : notice.status == 'draft'
                    ? const Color(0xFF888888)
                    : const Color(0xFFEF5350);

            return Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(children: [
                  Expanded(flex: 3, child: Text(notice.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 4, child: Text(notice.content, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)), overflow: TextOverflow.ellipsis, maxLines: 2)),
                  Expanded(flex: 1, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: priorityColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(notice.priority.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor), overflow: TextOverflow.ellipsis),
                  )),
                  Expanded(flex: 1, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(notice.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor), overflow: TextOverflow.ellipsis),
                  )),
                  Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(notice.authorName ?? 'Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                    Text('${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999))),
                  ])),
                  if (isEditor) Expanded(flex: 2, child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionBtn(isDark, Icons.edit_outlined, 'Edit', () => _showEditNoticeDialog(notice)),
                      const SizedBox(width: 6),
                      if (notice.status != 'published')
                        _buildActionBtn(isDark, Icons.publish_rounded, 'Publish', () {
                          context.read<AdminNoticesProvider>().publishNotice(notice.id);
                        }),
                      const SizedBox(width: 6),
                      _buildActionBtn(isDark, Icons.delete_outline_rounded, 'Delete', () => _showDeleteNoticeDialog(notice), danger: true),
                    ],
                  )),
                ]),
              ),
              Container(height: 1, color: borderColor),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildMobileCards(List<Notice> items, bool isDark, bool isEditor) {
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notice = items[index];
        final priorityColor = notice.priority == 'urgent' ? const Color(0xFFEF5350) : const Color(0xFF1E88E5);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notice.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(notice.priority.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(notice.content, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(children: [
              Text(notice.authorName ?? 'Admin', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999))),
              const Spacer(),
              Text('${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999))),
            ]),
            if (isEditor) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => _showEditNoticeDialog(notice),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                    side: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(
                  onPressed: () => _showDeleteNoticeDialog(notice),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF5350),
                    side: const BorderSide(color: Color(0xFFEF5350)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Delete', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                )),
              ]),
            ],
          ]),
        );
      },
    );
  }

  Widget _buildActionBtn(bool isDark, IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? const Color(0xFFEF5350) : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555));
    return Tooltip(
      message: label,
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(6), onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
          child: Icon(icon, size: 16, color: color),
        ),
      )),
    );
  }

  void _showCreateNoticeDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String priority = 'normal';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create Notice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(isDark, titleCtrl, 'Notice Title'),
        const SizedBox(height: 12),
        _dialogField(isDark, contentCtrl, 'Notice Content', maxLines: 4),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _priorityChip(isDark, 'Normal', priority == 'normal', () => setDialogState(() => priority = 'normal'))),
          const SizedBox(width: 6),
          Expanded(child: _priorityChip(isDark, 'Important', priority == 'important', () => setDialogState(() => priority = 'important'))),
          const SizedBox(width: 6),
          Expanded(child: _priorityChip(isDark, 'Urgent', priority == 'urgent', () => setDialogState(() => priority = 'urgent'))),
        ]),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.trim().isEmpty) return;
            final admin = context.read<AdminAuthProvider>().currentAdmin;
            context.read<AdminNoticesProvider>().createNotice(
              title: titleCtrl.text.trim(),
              content: contentCtrl.text.trim(),
              priority: priority,
              authorName: admin?.name ?? 'Admin',
            );
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A), foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    )));
  }

  Widget _priorityChip(bool isDark, String label, bool isActive, VoidCallback onTap) {
    return Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(8), onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? Colors.white : const Color(0xFF1A1A1A)) : (isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.transparent : (isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? (isDark ? const Color(0xFF1A1A1A) : Colors.white) : (isDark ? const Color(0xFF999999) : const Color(0xFF666666))))),
      ),
    ));
  }

  void _showEditNoticeDialog(Notice notice) {
    final titleCtrl = TextEditingController(text: notice.title);
    final contentCtrl = TextEditingController(text: notice.content);
    String priority = notice.priority;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Edit Notice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(isDark, titleCtrl, 'Notice Title'),
        const SizedBox(height: 12),
        _dialogField(isDark, contentCtrl, 'Notice Content', maxLines: 4),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _priorityChip(isDark, 'Normal', priority == 'normal', () => setDialogState(() => priority = 'normal'))),
          const SizedBox(width: 6),
          Expanded(child: _priorityChip(isDark, 'Important', priority == 'important', () => setDialogState(() => priority = 'important'))),
          const SizedBox(width: 6),
          Expanded(child: _priorityChip(isDark, 'Urgent', priority == 'urgent', () => setDialogState(() => priority = 'urgent'))),
        ]),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
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
          style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A), foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    )));
  }

  void _showDeleteNoticeDialog(Notice notice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Notice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: Text('Delete "${notice.title}"?\n\nThis action cannot be undone.', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666), fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () { context.read<AdminNoticesProvider>().deleteNotice(notice.id); Navigator.pop(ctx); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ));
  }

  Widget _dialogField(bool isDark, TextEditingController ctrl, String label, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF888888)),
        filled: true, fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
