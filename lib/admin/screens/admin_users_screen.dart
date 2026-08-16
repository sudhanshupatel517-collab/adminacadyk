import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_responsive.dart';
import '../data/admin_models.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
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
    final provider = context.watch<AdminUsersProvider>();
    final cardBg = isDark ? const Color(0xFF13171F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar & Controls
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('Add User', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A66C2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () => _showAddUserDialog(context),
                    ),
                    const SizedBox(height: 12),
                    AdminSearchBar(
                      controller: _searchCtrl,
                      hint: 'Search by name, email, or department...',
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
                      hint: 'Search users by name, email, or department...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterRow(provider, isDark),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_outlined, size: 16),
                    label: const Text('Add User', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () => _showAddUserDialog(context),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // User Table / Cards
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
                : provider.users.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: AdminEmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No users found',
                          subtitle: 'Try adjusting your search or filters.',
                          actionLabel: 'Add User',
                          onAction: () => _showAddUserDialog(context),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < AdminBreakpoints.mobile) {
                            return _buildMobileUserList(provider.users, isDark, borderColor, textPrimary, textSecondary);
                          }
                          return _buildDesktopTable(provider.users, isDark, borderColor, textPrimary, textSecondary);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AdminUsersProvider provider, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterDropdown(
          label: 'Status',
          value: provider.statusFilter,
          items: const [
            {'label': 'All Statuses', 'val': ''},
            {'label': 'Active', 'val': 'active'},
            {'label': 'Suspended', 'val': 'suspended'},
            {'label': 'Banned', 'val': 'banned'},
          ],
          onChanged: (v) => provider.setStatusFilter(v ?? ''),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterDropdown(
          label: 'Role',
          value: provider.roleFilter,
          items: const [
            {'label': 'All Roles', 'val': ''},
            {'label': 'Students', 'val': 'STUDENT'},
            {'label': 'Faculty', 'val': 'FACULTY'},
            {'label': 'Admin', 'val': 'ADMIN'},
          ],
          onChanged: (v) => provider.setRoleFilter(v ?? ''),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
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
          value: value,
          style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w500),
          dropdownColor: bg,
          icon: Icon(Icons.arrow_drop_down_rounded, size: 18, color: text),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['val'],
              child: Text(item['label']!),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
    List<ManagedUser> users,
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(2.0),
        3: FlexColumnWidth(1.0),
        4: FlexColumnWidth(1.2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : const Color(0xFFF9FAFB),
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          children: [
            _buildTableHeader('USER / EMAIL', isDark),
            _buildTableHeader('ROLE', isDark),
            _buildTableHeader('DEPARTMENT', isDark),
            _buildTableHeader('STATUS', isDark),
            _buildTableHeader('ACTIONS', isDark, alignRight: true),
          ],
        ),
        // Rows
        ...users.map((u) {
          return TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor.withOpacity(0.6))),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB),
                      child: Text(
                        u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.fullName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                          Text(u.email, style: TextStyle(fontSize: 11, color: textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(u.role, style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(u.department ?? 'General', style: TextStyle(fontSize: 12, color: textSecondary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildStatusBadge(u.status),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      tooltip: 'Edit User',
                      onPressed: () => _showEditUserDialog(context, u),
                    ),
                    IconButton(
                      icon: Icon(
                        u.status == 'active' ? Icons.block_flipped : Icons.check_circle_outline,
                        size: 16,
                        color: u.status == 'active' ? const Color(0xFFD97706) : const Color(0xFF059669),
                      ),
                      tooltip: u.status == 'active' ? 'Suspend User' : 'Activate User',
                      onPressed: () => context.read<AdminUsersProvider>().toggleUserStatus(u.id, u.status),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                      tooltip: 'Delete User',
                      onPressed: () => _showDeleteConfirmDialog(context, u),
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

  Widget _buildMobileUserList(
    List<ManagedUser> users,
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
      itemBuilder: (context, index) {
        final u = users[index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.fullName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                        Text(u.email, style: TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(u.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${u.role} - ${u.department ?? "General"}', style: TextStyle(fontSize: 12, color: textSecondary)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showEditUserDialog(context, u),
                        child: const Text('Edit', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: () => context.read<AdminUsersProvider>().toggleUserStatus(u.id, u.status),
                        child: Text(
                          u.status == 'active' ? 'Suspend' : 'Activate',
                          style: TextStyle(
                            fontSize: 12,
                            color: u.status == 'active' ? const Color(0xFFD97706) : const Color(0xFF059669),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showDeleteConfirmDialog(context, u),
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label = status.toUpperCase();

    if (status == 'active') {
      bg = const Color(0xFF059669).withOpacity(0.12);
      text = const Color(0xFF059669);
    } else if (status == 'suspended') {
      bg = const Color(0xFFD97706).withOpacity(0.12);
      text = const Color(0xFFD97706);
    } else {
      bg = const Color(0xFFDC2626).withOpacity(0.12);
      text = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
    );
  }

  // --- CRUD Modals ---
  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Computer Science');
    String selectedRole = 'STUDENT';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Add New User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. Rahul Sharma'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Institutional Email', hintText: 'e.g. rahul@acadyk.edu'),
                      validator: (v) => v?.trim().isEmpty == true || !v!.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                        DropdownMenuItem(value: 'FACULTY', child: Text('Faculty')),
                        DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                      ],
                      onChanged: (v) => setModalState(() => selectedRole = v ?? 'STUDENT'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deptCtrl,
                      decoration: const InputDecoration(labelText: 'Academic Department', hintText: 'e.g. Computer Science'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (formKey.currentState?.validate() == true) {
                    final success = await context.read<AdminUsersProvider>().addUser(
                          fullName: nameCtrl.text,
                          email: emailCtrl.text,
                          role: selectedRole,
                          department: deptCtrl.text,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User successfully added')),
                      );
                    }
                  }
                },
                child: const Text('Add User'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, ManagedUser user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final deptCtrl = TextEditingController(text: user.department ?? '');
    String selectedRole = user.role;
    String selectedStatus = user.status;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Edit User (${user.id})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Institutional Email'),
                      validator: (v) => v?.trim().isEmpty == true || !v!.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                        DropdownMenuItem(value: 'FACULTY', child: Text('Faculty')),
                        DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                      ],
                      onChanged: (v) => setModalState(() => selectedRole = v ?? 'STUDENT'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Account Status'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                        DropdownMenuItem(value: 'banned', child: Text('Banned')),
                      ],
                      onChanged: (v) => setModalState(() => selectedStatus = v ?? 'active'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deptCtrl,
                      decoration: const InputDecoration(labelText: 'Department'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (formKey.currentState?.validate() == true) {
                    final success = await context.read<AdminUsersProvider>().updateUser(
                          id: user.id,
                          fullName: nameCtrl.text,
                          email: emailCtrl.text,
                          role: selectedRole,
                          department: deptCtrl.text,
                          status: selectedStatus,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User record updated successfully')),
                      );
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ManagedUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to permanently delete user "${user.fullName}" (${user.email})? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await context.read<AdminUsersProvider>().deleteUser(user.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ${user.fullName} deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}