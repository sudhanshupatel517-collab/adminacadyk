import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_organizations_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../data/admin_mock_data.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';

class AdminOrganizationsScreen extends StatefulWidget {
  const AdminOrganizationsScreen({super.key});
  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  String _typeFilter = '';

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
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    final filtered = provider.organizations.where((o) {
      if (_typeFilter.isEmpty) return true;
      return o.type == _typeFilter;
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
                return Column(children: [
                  Row(children: [
                    Expanded(child: AdminSearchBar(hint: 'Search organizations...', onChanged: (q) => provider.setSearch(q))),
                    const SizedBox(width: 8),
                    _buildCreateButton(isDark, isEditor),
                  ]),
                  const SizedBox(height: 12),
                  _buildFilterChips(isDark),
                ]);
              }
              return Row(children: [
                Expanded(child: AdminSearchBar(hint: 'Search organizations...', onChanged: (q) => provider.setSearch(q))),
                const SizedBox(width: 16),
                _buildFilterChips(isDark),
                const SizedBox(width: 12),
                _buildCreateButton(isDark, isEditor),
              ]);
            },
          ),
          const SizedBox(height: 20),
          if (provider.isLoading)
            Center(child: Padding(padding: const EdgeInsets.all(60), child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF1A1A1A))))
          else if (filtered.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(60), child: Column(children: [
              Icon(Icons.groups_outlined, size: 48, color: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
              const SizedBox(height: 12),
              Text('No organizations found.', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))),
            ])))
          else
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth >= AdminBreakpoints.mobile) {
                return _buildDesktopTable(filtered, isDark, isEditor, cardBg, borderColor);
              }
              return _buildMobileCards(filtered, isDark, isEditor);
            }),
        ],
      ),
    );
  }

  Widget _buildCreateButton(bool isDark, bool isEditor) {
    if (!isEditor) return const SizedBox.shrink();
    return Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showCreateOrgDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: isDark ? Colors.white : const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add_rounded, size: 16, color: isDark ? const Color(0xFF1A1A1A) : Colors.white),
          const SizedBox(width: 6),
          Text('Create', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF1A1A1A) : Colors.white)),
        ]),
      ),
    ));
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'key': '', 'label': 'All'},
      {'key': 'club', 'label': 'Clubs'},
      {'key': 'team', 'label': 'Teams'},
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: filters.map((f) {
      final isActive = _typeFilter == f['key'];
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(color: Colors.transparent, child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _typeFilter = f['key']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? (isDark ? Colors.white : const Color(0xFF1A1A1A)) : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive ? Colors.transparent : (isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
            ),
            child: Text(f['label']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? (isDark ? const Color(0xFF1A1A1A) : Colors.white) : (isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
          ),
        )),
      );
    }).toList());
  }

  Widget _buildDesktopTable(List<Organization> items, bool isDark, bool isEditor, Color cardBg, Color borderColor) {
    final headerBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9);
    final headerText = isDark ? const Color(0xFF888888) : const Color(0xFF888888);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(color: headerBg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 3, child: Text('Organization', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
            Expanded(flex: 1, child: Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
            Expanded(flex: 2, child: Text('Department', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
            Expanded(flex: 1, child: Center(child: Text('Members', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
            Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
            if (isEditor) Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
          ]),
        ),
        Container(height: 1, color: borderColor),
        ...items.map((org) {
          final typeColor = org.isClub ? const Color(0xFF1E88E5) : const Color(0xFF7B1FA2);
          final statusColor = org.isActive ? const Color(0xFF00BA7C) : const Color(0xFF888888);
          return Column(children: [
            Material(color: Colors.transparent, child: InkWell(
              onTap: () => _showOrgDetailDialog(org),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(children: [
                  Expanded(flex: 3, child: Row(children: [
                    CircleAvatar(
                      radius: 16, backgroundColor: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      child: Icon(org.isClub ? Icons.groups_rounded : Icons.people_rounded, size: 16, color: typeColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(org.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis)),
                  ])),
                  Expanded(flex: 1, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: typeColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(org.type.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: typeColor), overflow: TextOverflow.ellipsis),
                  )),
                  Expanded(flex: 2, child: Text(org.department ?? '—', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)), overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 1, child: Center(child: Text('${org.memberIds.length}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555))))),
                  Expanded(flex: 1, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(org.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor), overflow: TextOverflow.ellipsis),
                  )),
                  if (isEditor) Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    _buildActionBtn(isDark, Icons.edit_outlined, 'Edit', () => _showEditOrgDialog(org)),
                    const SizedBox(width: 6),
                    _buildActionBtn(isDark, Icons.person_add_outlined, 'Add Member', () => _showAddMemberDialog(org)),
                    const SizedBox(width: 6),
                    if (org.isActive) _buildActionBtn(isDark, Icons.archive_outlined, 'Archive', () {
                      context.read<AdminOrganizationsProvider>().archiveOrganization(org.id);
                    }, danger: true),
                  ])),
                ]),
              ),
            )),
            Container(height: 1, color: borderColor),
          ]);
        }),
      ]),
    );
  }

  Widget _buildMobileCards(List<Organization> items, bool isDark, bool isEditor) {
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final org = items[index];
        final typeColor = org.isClub ? const Color(0xFF1E88E5) : const Color(0xFF7B1FA2);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 20, backgroundColor: typeColor.withValues(alpha: isDark ? 0.2 : 0.1), child: Icon(org.isClub ? Icons.groups_rounded : Icons.people_rounded, size: 20, color: typeColor)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(org.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                Text('${org.type.toUpperCase()} · ${org.memberIds.length} members', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999))),
              ])),
            ]),
            if (org.description != null) ...[
              const SizedBox(height: 10),
              Text(org.description!, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            if (isEditor) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => _showOrgDetailDialog(org),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                    side: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('View Members', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
    return Tooltip(message: label, child: Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(6), onTap: onTap,
      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))), child: Icon(icon, size: 16, color: color)),
    )));
  }

  void _showCreateOrgDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'club';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create Organization', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(isDark, nameCtrl, 'Name'),
        const SizedBox(height: 12),
        _dialogField(isDark, descCtrl, 'Description', maxLines: 2),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _typeChip(isDark, 'Club', type == 'club', () => setDialogState(() => type = 'club'))),
          const SizedBox(width: 8),
          Expanded(child: _typeChip(isDark, 'Team', type == 'team', () => setDialogState(() => type = 'team'))),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () {
            if (nameCtrl.text.trim().isEmpty) return;
            context.read<AdminOrganizationsProvider>().createOrganization(name: nameCtrl.text.trim(), type: type, description: descCtrl.text.trim());
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A), foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    )));
  }

  Widget _typeChip(bool isDark, String label, bool isActive, VoidCallback onTap) {
    return Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(8), onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? Colors.white : const Color(0xFF1A1A1A)) : (isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.transparent : (isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? (isDark ? const Color(0xFF1A1A1A) : Colors.white) : (isDark ? const Color(0xFF999999) : const Color(0xFF666666))))),
      ),
    ));
  }

  void _showEditOrgDialog(Organization org) {
    final nameCtrl = TextEditingController(text: org.name);
    final descCtrl = TextEditingController(text: org.description ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Edit Organization', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(isDark, nameCtrl, 'Name'),
        const SizedBox(height: 12),
        _dialogField(isDark, descCtrl, 'Description', maxLines: 2),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
        ElevatedButton(
          onPressed: () {
            context.read<AdminOrganizationsProvider>().updateOrganization(org.id, name: nameCtrl.text.trim(), description: descCtrl.text.trim());
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A), foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ));
  }

  void _showAddMemberDialog(Organization org) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableUsers = AdminMockData.users.where((u) => !org.memberIds.contains(u.id) && u.isActive).toList();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Member to ${org.name}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 400, height: 300, child: availableUsers.isEmpty
        ? Center(child: Text('No available users', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))))
        : ListView.builder(
          itemCount: availableUsers.length,
          itemBuilder: (context, index) {
            final user = availableUsers[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(radius: 16, backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0), child: Text(user.fullName[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
              title: Text(user.fullName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              subtitle: Text(user.enrollmentNumber ?? user.employeeId ?? user.email, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999))),
              trailing: IconButton(icon: Icon(Icons.add_circle_outline_rounded, color: const Color(0xFF00BA7C), size: 20), onPressed: () {
                context.read<AdminOrganizationsProvider>().addMember(org.id, user.id);
                Navigator.pop(ctx);
              }),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666))))],
    ));
  }

  void _showOrgDetailDialog(Organization org) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final members = AdminMockData.users.where((u) => org.memberIds.contains(u.id)).toList();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(org.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      content: SizedBox(width: 400, height: 350, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (org.description != null) ...[
          Text(org.description!, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF999999) : const Color(0xFF666666))),
          const SizedBox(height: 16),
        ],
        Text('Members (${members.length})', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Expanded(child: members.isEmpty
          ? Center(child: Text('No members', style: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF888888))))
          : ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final user = members[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                leading: CircleAvatar(radius: 16, backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0), child: Text(user.fullName[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
                title: Text(user.fullName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                subtitle: Text(user.enrollmentNumber ?? user.employeeId ?? user.email, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999))),
                trailing: IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF5350), size: 18), onPressed: () {
                  context.read<AdminOrganizationsProvider>().removeMember(org.id, user.id);
                  Navigator.pop(ctx);
                }),
              );
            },
          ),
        ),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666))))],
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
