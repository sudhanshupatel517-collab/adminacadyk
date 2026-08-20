import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_organizations_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../data/admin_mock_data.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminOrganizationsScreen extends StatefulWidget {
  const AdminOrganizationsScreen({super.key});
  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrganizationsProvider>().loadOrganizations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminOrganizationsProvider>();
    final isEditor = context.watch<AdminAuthProvider>().isEditor;
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    final filtered = provider.organizations.where((o) {
      if (_typeFilter == 'all' || _typeFilter.isEmpty) return true;
      return o.type.toLowerCase() == _typeFilter.toLowerCase();
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          AdminSectionHeader(
            title: 'Clubs & Teams',
            padding: const EdgeInsets.only(bottom: 16),
            trailing: isEditor
                ? ElevatedButton(
                    onPressed: _showCreateOrgDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.brand,
                      foregroundColor: isDark ? AppColors.brand : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Add Organization'),
                  )
                : null,
          ),

          // Header Controls
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    AdminSearchBar(hint: 'Search clubs & teams...', onChanged: (q) => provider.setSearch(q)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AdminFilterChips(
                        filters: const ['all', 'club', 'team'],
                        selected: _typeFilter,
                        onSelected: (f) => setState(() => _typeFilter = f),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: AdminSearchBar(hint: 'Search by club name, department, or description...', onChanged: (q) => provider.setSearch(q))),
                  const SizedBox(width: 14),
                  AdminFilterChips(
                    filters: const ['all', 'club', 'team'],
                    selected: _typeFilter,
                    onSelected: (f) => setState(() => _typeFilter = f),
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
                  'No clubs or teams match the selected filter.',
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

  Widget _buildDesktopTable(List<Organization> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
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
                Expanded(flex: 3, child: Text('ORGANIZATION NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('DEPARTMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Center(child: Text('MEMBERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
                if (isEditor)
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          ...items.map((org) {
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showOrgDetailDialog(org),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: AppColors.surfaceAlt(isDark),
                                  child: Text(
                                    org.name.isNotEmpty ? org.name[0].toUpperCase() : 'O',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.text(isDark)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    org.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(isDark),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                org.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSec(isDark),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              org.department ?? 'Institution-wide',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSec(isDark),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '${org.memberIds.length}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text(isDark),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AdminStatusBadge(status: org.status),
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
                                    onTap: () => _showEditOrgDialog(org),
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildTextActionBtn(
                                    label: 'Add Member',
                                    onTap: () => _showAddMemberDialog(org),
                                    isDark: isDark,
                                  ),
                                  if (org.isActive) ...[
                                    const SizedBox(width: 6),
                                    _buildTextActionBtn(
                                      label: 'Archive',
                                      onTap: () => context.read<AdminOrganizationsProvider>().archiveOrganization(org.id),
                                      isDanger: true,
                                      isDark: isDark,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
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

  Widget _buildMobileCards(List<Organization> items, bool isDark, bool isEditor) {
    final borderColor = AppColors.border(isDark);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final org = items[index];
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
                    radius: 14,
                    backgroundColor: AppColors.surfaceAlt(isDark),
                    child: Text(org.name.isNotEmpty ? org.name[0].toUpperCase() : 'O', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text(isDark))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(org.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                        Text('${org.type.toUpperCase()} · ${org.memberIds.length} members', style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark))),
                      ],
                    ),
                  ),
                  AdminStatusBadge(status: org.status),
                ],
              ),
              if (org.description != null && org.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  org.description!,
                  style: TextStyle(fontSize: 12, color: AppColors.textSec(isDark)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (isEditor) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showOrgDetailDialog(org),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('View Membership Roster', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
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

  void _showCreateOrgDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'club';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
          title: Text(
            'Create Organization',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(isDark, nameCtrl, 'Organization Name', required: true),
                const SizedBox(height: 12),
                _dialogField(isDark, descCtrl, 'Description', maxLines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Club', style: TextStyle(fontSize: 12))),
                        selected: type == 'club',
                        onSelected: (s) => setDialogState(() => type = 'club'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Team', style: TextStyle(fontSize: 12))),
                        selected: type == 'team',
                        onSelected: (s) => setDialogState(() => type = 'team'),
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
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<AdminOrganizationsProvider>().createOrganization(
                  name: nameCtrl.text.trim(),
                  type: type,
                  description: descCtrl.text.trim(),
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
              child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOrgDialog(Organization org) {
    final nameCtrl = TextEditingController(text: org.name);
    final descCtrl = TextEditingController(text: org.description ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
        title: Text(
          'Edit Organization',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(isDark, nameCtrl, 'Organization Name', required: true),
              const SizedBox(height: 12),
              _dialogField(isDark, descCtrl, 'Description', maxLines: 2),
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
              context.read<AdminOrganizationsProvider>().updateOrganization(
                org.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
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
    );
  }

  void _showAddMemberDialog(Organization org) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);
    final availableUsers = AdminMockData.users.where((u) => !org.memberIds.contains(u.id) && u.isActive).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
        title: Text(
          'Add Member to ${org.name}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
        ),
        content: SizedBox(
          width: 420,
          height: 320,
          child: availableUsers.isEmpty
              ? Center(child: Text('All eligible users are currently members.', style: TextStyle(color: AppColors.textMut(isDark), fontSize: 13)))
              : ListView.separated(
                  itemCount: availableUsers.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                  itemBuilder: (context, index) {
                    final user = availableUsers[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.surfaceAlt(isDark),
                        child: Text(user.fullName[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text(isDark))),
                      ),
                      title: Text(user.fullName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                      subtitle: Text(user.enrollmentNumber ?? user.employeeId ?? user.email, style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark))),
                      trailing: TextButton(
                        child: const Text('Add', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          context.read<AdminOrganizationsProvider>().addMember(org.id, user.id);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
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
            child: Text('Close', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showOrgDetailDialog(Organization org) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);
    final members = AdminMockData.users.where((u) => org.memberIds.contains(u.id)).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
        title: Text(
          org.name,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text(isDark)),
        ),
        content: SizedBox(
          width: 440,
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (org.description != null && org.description!.isNotEmpty) ...[
                Text(org.description!, style: TextStyle(fontSize: 12.5, color: AppColors.textSec(isDark))),
                const SizedBox(height: 14),
              ],
              Text(
                'Members (${members.length})',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(isDark)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: members.isEmpty
                    ? Center(child: Text('No members currently assigned.', style: TextStyle(color: AppColors.textMut(isDark), fontSize: 13)))
                    : ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                        itemBuilder: (context, index) {
                          final user = members[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            leading: CircleAvatar(
                              radius: 13,
                              backgroundColor: AppColors.surfaceAlt(isDark),
                              child: Text(user.fullName[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text(isDark))),
                            ),
                            title: Text(user.fullName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                            subtitle: Text(user.enrollmentNumber ?? user.employeeId ?? user.email, style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark))),
                            trailing: TextButton(
                              child: Text('Remove', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                              onPressed: () {
                                context.read<AdminOrganizationsProvider>().removeMember(org.id, user.id);
                                Navigator.pop(ctx);
                              },
                            ),
                          );
                        },
                      ),
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
            child: Text('Close', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppColors.text(isDark), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}
