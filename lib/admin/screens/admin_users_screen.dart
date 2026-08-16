import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/admin_models.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_responsive.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
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
    final provider = context.watch<AdminUsersProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Directory',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage student and faculty accounts, roles, and status',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context, isDark),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters Bar
          _buildFiltersBar(context, isDark, provider),
          const SizedBox(height: 16),

          // Users Table / List
          if (provider.state == UserLoadState.loading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            )
          else if (provider.state == UserLoadState.error)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  provider.error ?? 'Failed to load users',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          else if (provider.users.isEmpty)
            _buildEmptyState(isDark)
          else
            _buildUserTable(context, isDark, provider),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(BuildContext context, bool isDark, AdminUsersProvider provider) {
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
          // Search Field
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearch(val),
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: 'Search name, email, department...',
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

          // Status Filter Dropdown
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
                  DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  DropdownMenuItem(value: 'banned', child: Text('Banned')),
                ],
                onChanged: (val) => provider.setStatusFilter(val),
              ),
            ),
          ),

          // Role Filter Dropdown
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
                value: provider.roleFilter ?? 'all',
                dropdownColor: cardBg,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'STUDENT', child: Text('Students')),
                  DropdownMenuItem(value: 'FACULTY', child: Text('Faculty')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Admins')),
                ],
                onChanged: (val) => provider.setRoleFilter(val),
              ),
            ),
          ),

          // Results counter
          Text(
            '${provider.users.length} accounts found',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
            ),
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
          Icon(Icons.person_off_rounded, size: 48, color: isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC)),
          const SizedBox(height: 12),
          Text(
            'No matching users found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try resetting your search query or filter options.',
            style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF666666) : const Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(BuildContext context, bool isDark, AdminUsersProvider provider) {
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
              _buildHeaderCell('User', isDark),
              _buildHeaderCell('Role', isDark),
              _buildHeaderCell('Department', isDark),
              _buildHeaderCell('Status', isDark),
              _buildHeaderCell('Posts', isDark),
              _buildHeaderCell('Actions', isDark),
            ],
            rows: provider.users.map((user) {
              return DataRow(
                cells: [
                  // User Name & Email
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF666666) : const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Role
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),

                  // Department
                  DataCell(
                    Text(
                      user.department ?? 'General',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                      ),
                    ),
                  ),

                  // Status
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.status == 'active'
                            ? const Color(0xFF00BA7C).withValues(alpha: 0.12)
                            : (user.status == 'suspended'
                                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                : const Color(0xFFEF5350).withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: user.status == 'active'
                              ? const Color(0xFF00BA7C)
                              : (user.status == 'suspended' ? const Color(0xFFF59E0B) : const Color(0xFFEF5350)),
                        ),
                      ),
                    ),
                  ),

                  // Posts Count
                  DataCell(
                    Text(
                      '${user.postsCount}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  // Actions
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          tooltip: 'Edit User',
                          onPressed: () => _showEditUserDialog(context, user, isDark),
                        ),
                        // Suspend / Activate Toggle
                        IconButton(
                          icon: Icon(
                            user.status == 'active' ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                            size: 16,
                            color: user.status == 'active' ? const Color(0xFFF59E0B) : const Color(0xFF00BA7C),
                          ),
                          tooltip: user.status == 'active' ? 'Suspend User' : 'Activate User',
                          onPressed: () async {
                            final success = await provider.toggleUserStatus(user.id, user.status);
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User status updated to ${user.status == "active" ? "suspended" : "active"}')),
                              );
                            }
                          },
                        ),
                        // Delete
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF5350)),
                          tooltip: 'Delete User',
                          onPressed: () => _showDeleteUserDialog(context, user, isDark),
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

  // -- Modals --
  void _showAddUserDialog(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    String selectedRole = 'STUDENT';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Add New User', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *', hintText: 'e.g. Rahul Sharma'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a full name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address *', hintText: 'e.g. rahul@acadyk.edu'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter an email';
                    if (!v.contains('@') || !v.contains('.')) return 'Please enter a valid email address';
                    return null;
                  },
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
                  onChanged: (v) => selectedRole = v ?? 'STUDENT',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: deptCtrl,
                  decoration: const InputDecoration(labelText: 'Department', hintText: 'e.g. Computer Science'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final success = await context.read<AdminUsersProvider>().addUser(
                  fullName: nameCtrl.text,
                  email: emailCtrl.text,
                  role: selectedRole,
                  department: deptCtrl.text,
                );
                if (ctx.mounted && success) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New user added successfully.')),
                  );
                }
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, ManagedUser user, bool isDark) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final deptCtrl = TextEditingController(text: user.department ?? '');
    String selectedRole = user.role;
    String selectedStatus = user.status;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit User: ${user.fullName}', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a full name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address *'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
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
                  onChanged: (v) => selectedRole = v ?? 'STUDENT',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                    DropdownMenuItem(value: 'banned', child: Text('Banned')),
                  ],
                  onChanged: (v) => selectedStatus = v ?? 'active',
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final success = await context.read<AdminUsersProvider>().updateUser(
                  user.id,
                  fullName: nameCtrl.text,
                  email: emailCtrl.text,
                  role: selectedRole,
                  status: selectedStatus,
                  department: deptCtrl.text,
                );
                if (ctx.mounted && success) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully.')),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, ManagedUser user, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete User Account', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF5350))),
        content: Text(
          'Are you sure you want to permanently delete "${user.fullName}" (${user.email})? This action cannot be undone.',
          style: TextStyle(color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white),
            onPressed: () async {
              final success = await context.read<AdminUsersProvider>().deleteUser(user.id);
              if (ctx.mounted && success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User "${user.fullName}" deleted.')),
                );
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}