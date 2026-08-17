import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_users_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../data/admin_mock_data.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _filter = 'all';
  bool _showingDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminUsersProvider>();
    final isEditor = context.watch<AdminAuthProvider>().isEditor;
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    if (_showingDetail && provider.selectedUser != null) {
      return AdminUserDetailScreen(
        onBack: () {
          setState(() {
            _showingDetail = false;
          });
          provider.clearSelectedUser();
        },
      );
    }

    final filteredUsers = provider.users.where((u) {
      if (_filter == 'all') return true;
      if (_filter == 'active') return u.status == 'active';
      if (_filter == 'suspended') return u.status == 'suspended';
      if (_filter == 'student') return u.role == 'STUDENT';
      if (_filter == 'faculty') return u.role == 'FACULTY';
      return true;
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
                        Expanded(
                          child: AdminSearchBar(
                            hint: 'Search by name, email, ID...',
                            onChanged: (q) => provider.setSearch(q),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterButton(isDark, provider),
                        if (isEditor) ...[
                          const SizedBox(width: 8),
                          _buildAddUserButton(isDark),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildFilterChips(isDark),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminSearchBar(
                          hint: 'Search users by name, email, enrollment (BTAM...) or employee ID...',
                          onChanged: (q) => provider.setSearch(q),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildDesktopFilters(isDark, provider),
                      const SizedBox(width: 12),
                      _buildFilterChips(isDark),
                      if (isEditor) ...[
                        const SizedBox(width: 12),
                        _buildAddUserButton(isDark),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < AdminBreakpoints.mobile) {
                  return _buildMobileCards(filteredUsers, isDark, isEditor);
                }
                return _buildDesktopTable(filteredUsers, isDark, isEditor, borderColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showAddUserDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add_rounded, size: 16, color: isDark ? const Color(0xFF1A1A1A) : Colors.white),
              const SizedBox(width: 6),
              Text(
                'Add User',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFilters(bool isDark, AdminUsersProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDropdown(
          isDark: isDark,
          hint: 'Course',
          value: provider.courseFilter,
          items: ['all', ...AdminMockData.courses],
          onChanged: (val) => provider.setCourseFilter(val == 'all' ? null : val),
        ),
        const SizedBox(width: 8),
        _buildDropdown(
          isDark: isDark,
          hint: 'Branch',
          value: provider.branchFilter,
          items: ['all', ...AdminMockData.branches],
          onChanged: (val) => provider.setBranchFilter(val == 'all' ? null : val),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required bool isDark,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(Icons.arrow_drop_down, size: 18, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)),
          items: items.map((i) => DropdownMenuItem(
            value: i == 'all' ? null : i,
            child: Text(i == 'all' ? 'All ${hint}s' : i),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isDark, AdminUsersProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
      ),
      child: IconButton(
        icon: Icon(Icons.filter_list_rounded, size: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
        onPressed: () => _showMobileFilterBottomSheet(isDark, provider),
        tooltip: 'Filters',
      ),
    );
  }

  void _showMobileFilterBottomSheet(bool isDark, AdminUsersProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      provider.clearAllFilters();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset All', style: TextStyle(color: Color(0xFFEF5350))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Course', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AdminMockData.courses.map((c) {
                  final active = provider.courseFilter == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: active,
                    onSelected: (selected) {
                      setModalState(() {
                        provider.setCourseFilter(selected ? c : null);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AdminMockData.branches.map((b) {
                  final active = provider.branchFilter == b;
                  return ChoiceChip(
                    label: Text(b),
                    selected: active,
                    onSelected: (selected) {
                      setModalState(() {
                        provider.setBranchFilter(selected ? b : null);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = ['all', 'active', 'suspended', 'student', 'faculty'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: filters.map((f) {
        final isActive = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _filter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                      : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive
                      ? Colors.transparent
                      : (isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
                ),
                child: Text(
                  f[0].toUpperCase() + f.substring(1),
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isActive
                        ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
                        : (isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTable(List<ManagedUser> users, bool isDark, bool isEditor, Color borderColor) {
    final headerBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9);
    final headerText = isDark ? const Color(0xFF888888) : const Color(0xFF888888);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('User', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 2, child: Text('ID / Enrollment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 2, child: Text('Dept / Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Center(child: Text('Posts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
              if (isEditor)
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
            ],
          ),
        ),
        Container(height: 1, color: borderColor),
        ...users.map((user) {
          final isUserActive = user.status == 'active';
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await context.read<AdminUsersProvider>().selectUser(user.id);
                    setState(() {
                      _showingDetail = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                              child: Text(user.fullName[0].toUpperCase(), style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName, style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ), overflow: TextOverflow.ellipsis),
                                Text(user.email, style: TextStyle(
                                  fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                                ), overflow: TextOverflow.ellipsis),
                              ],
                            )),
                          ],
                        )),
                        Expanded(flex: 2, child: Text(
                          user.enrollmentNumber ?? user.employeeId ?? '—',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444),
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Expanded(flex: 2, child: Text(
                          user.branch != null ? '${user.course ?? ""} - ${user.branch}' : (user.department ?? '—'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Expanded(flex: 1, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(user.role, style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                          )),
                        )),
                        Expanded(flex: 1, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isUserActive
                                ? (isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9))
                                : (isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFCE4EC)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(user.status.toUpperCase(), style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: isUserActive
                                ? (isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32))
                                : (isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828)),
                          )),
                        )),
                        Expanded(flex: 1, child: Center(child: Text('${user.postsCount}', style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                        )))),
                        if (isEditor)
                          Expanded(flex: 2, child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionBtn(isDark, Icons.visibility_outlined, 'View Details', () async {
                                await context.read<AdminUsersProvider>().selectUser(user.id);
                                setState(() => _showingDetail = true);
                              }),
                              const SizedBox(width: 6),
                              _buildActionBtn(isDark,
                                isUserActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                                isUserActive ? 'Suspend' : 'Activate',
                                () => _handleUserStatus(user),
                                danger: isUserActive,
                              ),
                            ],
                          )),
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 1, color: borderColor),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildActionBtn(bool isDark, IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger
        ? (isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828))
        : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555));
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(List<ManagedUser> users, bool isDark, bool isEditor) {
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    return Column(
      children: users.map((user) {
        final isUserActive = user.status == 'active';
        return InkWell(
          onTap: () async {
            await context.read<AdminUsersProvider>().selectUser(user.id);
            setState(() => _showingDetail = true);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                      child: Text(user.fullName[0].toUpperCase(), style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        )),
                        Text(
                          user.enrollmentNumber ?? user.employeeId ?? user.email,
                          style: TextStyle(
                            fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUserActive
                            ? (isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9))
                            : (isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFCE4EC)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(user.status.toUpperCase(), style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: isUserActive
                            ? (isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32))
                            : (isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828)),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMobileTag(isDark, user.role),
                    const SizedBox(width: 8),
                    if (user.branch != null) _buildMobileTag(isDark, user.branch!),
                    const Spacer(),
                    Text('${user.postsCount} posts', style: TextStyle(
                      fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                    )),
                  ],
                ),
                if (isEditor) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleUserStatus(user),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isUserActive
                            ? (isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828))
                            : (isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32)),
                        side: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(isUserActive ? 'Suspend' : 'Activate', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileTag(bool isDark, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
      )),
    );
  }

  void _handleUserStatus(ManagedUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (user.status == 'active') {
      final reasonCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Suspend User Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Suspend access for ${user.fullName} (${user.email}). Provide an audit reason:', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666), fontSize: 14)),
              const SizedBox(height: 14),
              TextField(
                controller: reasonCtrl, maxLines: 3,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'e.g. Violation of platform conduct rules...',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA), fontSize: 13),
                  filled: true, fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
            ElevatedButton(
              onPressed: () {
                final reason = reasonCtrl.text.trim().isEmpty ? 'Administrative action' : reasonCtrl.text.trim();
                final admin = context.read<AdminAuthProvider>().currentAdmin;
                context.read<AdminUsersProvider>().suspendUser(user.id, reason, admin?.name ?? 'Admin');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Suspend', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );
    } else {
      final admin = context.read<AdminAuthProvider>().currentAdmin;
      context.read<AdminUsersProvider>().restoreUser(user.id, admin?.name ?? 'Admin');
    }
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String role = 'STUDENT';
    String course = 'B.Tech';
    String branch = 'AIML';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New User', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(isDark, nameCtrl, 'Full Name'),
                  const SizedBox(height: 12),
                  _dialogField(isDark, emailCtrl, 'Email (@acadyk.edu)'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Student')),
                          selected: role == 'STUDENT',
                          onSelected: (s) => setDialogState(() => role = 'STUDENT'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Faculty')),
                          selected: role == 'FACULTY',
                          onSelected: (s) => setDialogState(() => role = 'FACULTY'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    isDark,
                    idCtrl,
                    role == 'STUDENT' ? 'Enrollment Number (e.g. BTAM25O1062)' : 'Employee ID (e.g. EMP1025)',
                  ),
                  const SizedBox(height: 12),
                  if (role == 'STUDENT') ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: course,
                            decoration: InputDecoration(
                              labelText: 'Course',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            items: AdminMockData.courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setDialogState(() => course = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: branch,
                            decoration: InputDecoration(
                              labelText: 'Branch',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            items: AdminMockData.branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                            onChanged: (v) => setDialogState(() => branch = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  _dialogField(isDark, phoneCtrl, 'Phone Number'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                context.read<AdminUsersProvider>().addUser(
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  role: role,
                  enrollmentNumber: role == 'STUDENT' ? idCtrl.text.trim() : null,
                  employeeId: role == 'FACULTY' ? idCtrl.text.trim() : null,
                  course: role == 'STUDENT' ? course : null,
                  branch: role == 'STUDENT' ? branch : null,
                  phone: phoneCtrl.text.trim(),
                  department: role == 'FACULTY' ? 'Computer Science & Engineering' : null,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(bool isDark, TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF888888)),
        filled: true,
        fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}