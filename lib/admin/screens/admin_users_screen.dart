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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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
          // Filter & Search Controls
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
                            hint: 'Search users...',
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
              return Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      hint: 'Search by name, email, enrollment (BTAM...) or employee ID...',
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
              );
            },
          ),
          const SizedBox(height: 18),

          // User Table Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (provider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  );
                }

                if (filteredUsers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.person_search_outlined, size: 36, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            'No user accounts match the current filters.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

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
    return ElevatedButton.icon(
      onPressed: () => _showAddUserDialog(),
      icon: const Icon(Icons.person_add_rounded, size: 16),
      label: const Text('Add User'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: IconButton(
        icon: Icon(Icons.tune_rounded, size: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        onPressed: () => _showMobileFilterBottomSheet(isDark, provider),
        tooltip: 'Filters',
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showMobileFilterBottomSheet(bool isDark, AdminUsersProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      provider.clearAllFilters();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset All', style: TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Course', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AdminMockData.courses.map((c) {
                  final active = provider.courseFilter == c;
                  return ChoiceChip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    selected: active,
                    onSelected: (selected) {
                      setModalState(() {
                        provider.setCourseFilter(selected ? c : null);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text('Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AdminMockData.branches.map((b) {
                  final active = provider.branchFilter == b;
                  return ChoiceChip(
                    label: Text(b, style: const TextStyle(fontSize: 12)),
                    selected: active,
                    onSelected: (selected) {
                      setModalState(() {
                        provider.setBranchFilter(selected ? b : null);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'active', 'label': 'Active'},
      {'key': 'suspended', 'label': 'Suspended'},
      {'key': 'student', 'label': 'Students'},
      {'key': 'faculty', 'label': 'Faculty'},
    ];
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: filters.map((f) {
        final isActive = _filter == f['key'];
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _filter = f['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isActive ? Colors.transparent : borderColor, width: 1),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
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
    final headerBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final headerText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final rowDivider = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('NAME & EMAIL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('ENROLLMENT / ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
              Expanded(flex: 2, child: Text('DEPT / BRANCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
              Expanded(flex: 1, child: Text('ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
              Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5))),
              Expanded(flex: 1, child: Center(child: Text('POSTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
              if (isEditor)
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.5)))),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                child: Text(
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            user.enrollmentNumber ?? user.employeeId ?? '—',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            user.branch != null ? '${user.course ?? ""} - ${user.branch}' : (user.department ?? '—'),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                              child: Text(
                                user.role,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUserActive
                                    ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4))
                                    : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2)),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isUserActive
                                      ? (isDark ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFBBF7D0))
                                      : (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.3) : const Color(0xFFFECACA)),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                user.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isUserActive
                                      ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                                      : (isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              '${user.postsCount}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                        if (isEditor)
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionBtn(
                                  isDark: isDark,
                                  icon: Icons.visibility_outlined,
                                  label: 'View Details',
                                  onTap: () async {
                                    await context.read<AdminUsersProvider>().selectUser(user.id);
                                    setState(() => _showingDetail = true);
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildActionBtn(
                                  isDark: isDark,
                                  icon: isUserActive ? Icons.block_outlined : Icons.check_circle_outline_rounded,
                                  label: isUserActive ? 'Suspend Account' : 'Activate Account',
                                  onTap: () => _handleUserStatus(user),
                                  isDanger: isUserActive,
                                ),
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
    );
  }

  Widget _buildActionBtn({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final color = isDanger
        ? const Color(0xFFDC2626)
        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569));

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(List<ManagedUser> users, bool isDark, bool isEditor) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
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
                      radius: 16,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            user.enrollmentNumber ?? user.employeeId ?? user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUserActive
                            ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4))
                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2)),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isUserActive
                              ? (isDark ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFBBF7D0))
                              : (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.3) : const Color(0xFFFECACA)),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isUserActive
                              ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                              : (isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMobileTag(isDark, user.role),
                    const SizedBox(width: 6),
                    if (user.branch != null) _buildMobileTag(isDark, user.branch!),
                    const Spacer(),
                    Text(
                      '${user.postsCount} posts',
                      style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileTag(bool isDark, String text) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
    );
  }

  void _handleUserStatus(ManagedUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    if (user.status == 'active') {
      final reasonCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Text(
            'Suspend User Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suspend access for ${user.fullName} (${user.email}). Provide an audit reason:',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'e.g. Violation of academic integrity...',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 13),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonCtrl.text.trim().isEmpty ? 'Administrative action' : reasonCtrl.text.trim();
                final admin = context.read<AdminAuthProvider>().currentAdmin;
                context.read<AdminUsersProvider>().suspendUser(user.id, reason, admin?.name ?? 'Admin');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              ),
              child: const Text('Suspend User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Text(
            'Add User Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(isDark, nameCtrl, 'Full Name', required: true),
                  const SizedBox(height: 12),
                  _dialogField(isDark, emailCtrl, 'Email Address (@mitsgwl.ac.in)', required: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Student', style: TextStyle(fontSize: 12))),
                          selected: role == 'STUDENT',
                          onSelected: (s) => setDialogState(() => role = 'STUDENT'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Faculty', style: TextStyle(fontSize: 12))),
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
                            initialValue: course,
                            decoration: InputDecoration(
                              labelText: 'Course',
                              labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            items: AdminMockData.courses.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setDialogState(() => course = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: branch,
                            decoration: InputDecoration(
                              labelText: 'Branch',
                              labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            items: AdminMockData.branches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13)))).toList(),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
            ),
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
                backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Add User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(bool isDark, TextEditingController ctrl, String label, {bool required = false}) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: isDark ? Colors.white : const Color(0xFF0F172A), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}