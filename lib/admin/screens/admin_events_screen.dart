import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/admin_events_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});
  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  String _statusFilter = 'all';
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

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
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    final filtered = provider.events.where((e) {
      if (_statusFilter == 'all' || _statusFilter.isEmpty) return true;
      return e.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          AdminSectionHeader(
            title: 'Event Management',
            padding: const EdgeInsets.only(bottom: 16),
            trailing: isEditor
                ? ElevatedButton(
                    onPressed: _showCreateEventDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.brand,
                      foregroundColor: isDark ? AppColors.brand : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Create Event'),
                  )
                : null,
          ),

          // Filter & Search Controls
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    AdminSearchBar(hint: 'Search events...', onChanged: (q) => provider.setSearch(q)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AdminFilterChips(
                        filters: const ['all', 'published', 'scheduled', 'draft', 'cancelled', 'completed'],
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
                    child: AdminSearchBar(hint: 'Search by title, organizer, or venue...', onChanged: (q) => provider.setSearch(q)),
                  ),
                  const SizedBox(width: 14),
                  AdminFilterChips(
                    filters: const ['all', 'published', 'scheduled', 'draft', 'cancelled', 'completed'],
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
                  'No campus events match the selected criteria.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSec(isDark),
                  ),
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

  Widget _buildDesktopTable(List<ManagedEvent> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
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
                Expanded(flex: 3, child: Text('EVENT TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('ORGANIZER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Center(child: Text('ATTENDEES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
                if (isEditor) Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((event) {
            final dateStr = event.startDate != null ? _dateFormat.format(event.startDate!) : 'TBD';
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          event.title,
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
                          event.organizer,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSec(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMut(isDark),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AdminStatusBadge(status: event.status),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            '${event.registrationsCount}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(isDark),
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
                              _buildTextActionBtn(
                                label: 'Edit',
                                onTap: () => _showEditEventDialog(event),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 6),
                              if (event.isDraft) ...[
                                _buildTextActionBtn(
                                  label: 'Publish',
                                  onTap: () => context.read<AdminEventsProvider>().updateEventStatus(event.id, 'published'),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (event.isPublished) ...[
                                _buildTextActionBtn(
                                  label: 'Cancel',
                                  onTap: () => context.read<AdminEventsProvider>().updateEventStatus(event.id, 'cancelled'),
                                  isDanger: true,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                              ],
                              _buildTextActionBtn(
                                label: 'Delete',
                                onTap: () => _showDeleteDialog(event),
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

  Widget _buildMobileCards(List<ManagedEvent> items, bool isDark, bool isEditor) {
    final borderColor = AppColors.border(isDark);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = items[index];
        final dateStr = event.startDate != null ? _dateFormat.format(event.startDate!) : 'TBD';
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
                      event.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(isDark),
                      ),
                    ),
                  ),
                  AdminStatusBadge(status: event.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Organizer: ${event.organizer}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSec(isDark),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark)),
                  ),
                  const Spacer(),
                  Text(
                    '${event.registrationsCount} attendees',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textSec(isDark)),
                  ),
                ],
              ),
              if (isEditor) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showEditEventDialog(event),
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
                        onPressed: () => _showDeleteDialog(event),
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

  void _showCreateEventDialog() {
    _showEventFormDialog(null);
  }

  void _showEditEventDialog(ManagedEvent event) {
    _showEventFormDialog(event);
  }

  void _showEventFormDialog(ManagedEvent? existing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final orgCtrl = TextEditingController(text: existing?.organizer ?? '');
    final venueCtrl = TextEditingController(text: existing?.venue ?? '');
    String status = existing?.status ?? 'published';
    DateTime? startDate = existing?.startDate ?? DateTime.now().add(const Duration(days: 7));
    DateTime? endDate = existing?.endDate ?? DateTime.now().add(const Duration(days: 7, hours: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
          title: Text(
            existing == null ? 'Create Campus Event' : 'Edit Event Details',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text(isDark)),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                    decoration: const InputDecoration(hintText: 'e.g. Annual Tech Symposium 2026', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                  const SizedBox(height: 12),
                  Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                    decoration: const InputDecoration(hintText: 'Provide event details and agenda...', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Organizer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: orgCtrl,
                              style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                              decoration: const InputDecoration(hintText: 'Department or Club', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Venue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: venueCtrl,
                              style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                              decoration: const InputDecoration(hintText: 'Auditorium / Lab', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                    dropdownColor: AppColors.surfaceColor(isDark),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: const [
                      DropdownMenuItem(value: 'published', child: Text('Published')),
                      DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    ],
                    onChanged: (val) => setDialogState(() => status = val!),
                  ),
                  const SizedBox(height: 12),
                  Text('Event Date: ${startDate != null ? _dateFormat.format(startDate!) : "Not set"}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.text(isDark))),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          startDate = picked;
                          endDate = picked.add(const Duration(hours: 3));
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Select Event Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
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
                if (titleCtrl.text.trim().isEmpty) return;
                final provider = context.read<AdminEventsProvider>();
                if (existing == null) {
                  provider.createEvent(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    organizer: orgCtrl.text.trim().isEmpty ? 'Institution' : orgCtrl.text.trim(),
                    venue: venueCtrl.text.trim().isEmpty ? 'Main Campus' : venueCtrl.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                    status: status,
                  );
                } else {
                  provider.updateEvent(
                    existing.id,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    organizer: orgCtrl.text.trim(),
                    venue: venueCtrl.text.trim(),
                    status: status,
                  );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.brand,
                foregroundColor: isDark ? AppColors.brand : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(existing == null ? 'Create Event' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(ManagedEvent event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
        title: Text(
          'Delete Event',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
        ),
        content: Text(
          'Permanently remove "${event.title}" from institutional records? This action cannot be reversed.',
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
              context.read<AdminEventsProvider>().deleteEvent(event.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Delete Event', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
