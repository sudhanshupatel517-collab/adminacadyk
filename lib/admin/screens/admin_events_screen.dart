import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_events_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});
  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEventsProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminEventsProvider>();
    final isEditor = context.watch<AdminAuthProvider>().isEditor;
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    final filtered = provider.events.where((e) {
      if (_statusFilter.isEmpty) return true;
      return e.status == _statusFilter;
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
                        Expanded(child: AdminSearchBar(hint: 'Search events...', onChanged: (q) => provider.setSearch(q))),
                        const SizedBox(width: 8),
                        _buildCreateButton(isDark, isEditor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildFilterChips(isDark)),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: AdminSearchBar(hint: 'Search events...', onChanged: (q) => provider.setSearch(q))),
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
              Icon(Icons.event_busy_outlined, size: 48, color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
              const SizedBox(height: 12),
              Text('No events found.', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
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
        onTap: () => _showCreateEventDialog(),
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
              Text('Create Event', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF1A1A1A) : Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'key': '', 'label': 'All'},
      {'key': 'draft', 'label': 'Draft'},
      {'key': 'scheduled', 'label': 'Scheduled'},
      {'key': 'published', 'label': 'Published'},
      {'key': 'cancelled', 'label': 'Cancelled'},
      {'key': 'completed', 'label': 'Completed'},
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

  Widget _buildDesktopTable(List<ManagedEvent> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
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
              Expanded(flex: 3, child: Text('Event', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 2, child: Text('Organizer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Center(child: Text('Registrations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
              if (isEditor) Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
            ]),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((event) {
            final statusColor = _statusColor(event.status);
            return Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(children: [
                  Expanded(flex: 3, child: Text(event.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 2, child: Text(event.organizer, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)), overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 2, child: Text(event.startDate != null ? '${event.startDate!.day}/${event.startDate!.month}/${event.startDate!.year}' : 'TBD', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)))),
                  Expanded(flex: 1, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(event.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor), overflow: TextOverflow.ellipsis),
                  )),
                  Expanded(flex: 1, child: Center(child: Text('${event.registrationsCount}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555))))),
                  if (isEditor) Expanded(flex: 2, child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionBtn(isDark, Icons.edit_outlined, 'Edit', () => _showEditEventDialog(event)),
                      const SizedBox(width: 6),
                      if (event.isDraft) _buildActionBtn(isDark, Icons.publish_rounded, 'Publish', () => context.read<AdminEventsProvider>().updateEventStatus(event.id, 'published')),
                      if (event.isPublished) _buildActionBtn(isDark, Icons.cancel_outlined, 'Cancel', () => context.read<AdminEventsProvider>().updateEventStatus(event.id, 'cancelled'), danger: true),
                      const SizedBox(width: 6),
                      _buildActionBtn(isDark, Icons.delete_outline_rounded, 'Delete', () => _showDeleteDialog(event), danger: true),
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

  Widget _buildMobileCards(List<ManagedEvent> items, bool isDark, bool isEditor) {
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = items[index];
        final statusColor = _statusColor(event.status);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(event.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(event.organizer, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
              const SizedBox(width: 4),
              Text(event.startDate != null ? '${event.startDate!.day}/${event.startDate!.month}/${event.startDate!.year}' : 'TBD', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999))),
              const Spacer(),
              Text('${event.registrationsCount} registered', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999))),
            ]),
            if (isEditor) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => _showEditEventDialog(event),
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
                  onPressed: () => _showDeleteDialog(event),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'published': return const Color(0xFF00BA7C);
      case 'scheduled': return const Color(0xFF1E88E5);
      case 'draft': return const Color(0xFF888888);
      case 'cancelled': return const Color(0xFFEF5350);
      case 'completed': return const Color(0xFF7B1FA2);
      default: return const Color(0xFF888888);
    }
  }

  void _showCreateEventDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    final organizerCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create Event', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(isDark, titleCtrl, 'Event Title'),
        const SizedBox(height: 12),
        _dialogField(isDark, descCtrl, 'Description', maxLines: 3),
        const SizedBox(height: 12),
        _dialogField(isDark, venueCtrl, 'Venue'),
        const SizedBox(height: 12),
        _dialogField(isDark, organizerCtrl, 'Organizer'),
        const SizedBox(height: 12),
        _dialogField(isDark, contactCtrl, 'Contact Info'),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.trim().isEmpty) return;
            final admin = context.read<AdminAuthProvider>().currentAdmin;
            context.read<AdminEventsProvider>().createEvent(
              title: titleCtrl.text.trim(),
              description: descCtrl.text.trim(),
              venue: venueCtrl.text.trim(),
              organizer: organizerCtrl.text.trim(),
              contactInfo: contactCtrl.text.trim(),
              createdBy: admin?.name ?? 'Admin',
            );
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
            foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ));
  }

  void _showEditEventDialog(ManagedEvent event) {
    final titleCtrl = TextEditingController(text: event.title);
    final descCtrl = TextEditingController(text: event.description);
    final venueCtrl = TextEditingController(text: event.venue);
    final organizerCtrl = TextEditingController(text: event.organizer);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Edit Event', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(isDark, titleCtrl, 'Event Title'),
        const SizedBox(height: 12),
        _dialogField(isDark, descCtrl, 'Description', maxLines: 3),
        const SizedBox(height: 12),
        _dialogField(isDark, venueCtrl, 'Venue'),
        const SizedBox(height: 12),
        _dialogField(isDark, organizerCtrl, 'Organizer'),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () {
            context.read<AdminEventsProvider>().updateEvent(event.id,
              title: titleCtrl.text.trim(), description: descCtrl.text.trim(),
              venue: venueCtrl.text.trim(), organizer: organizerCtrl.text.trim(),
            );
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
            foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ));
  }

  void _showDeleteDialog(ManagedEvent event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Event', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: Text('Delete "${event.title}"?\n\nThis action cannot be undone.', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666), fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () { context.read<AdminEventsProvider>().deleteEvent(event.id); Navigator.pop(ctx); },
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
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF888888)),
        filled: true, fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
