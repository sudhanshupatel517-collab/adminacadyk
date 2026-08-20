import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_users_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../data/admin_mock_data.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_section_header.dart';
import '../widgets/admin_user_form_dialog.dart';
import 'admin_user_detail_screen.dart';
import '../../app/theme/app_colors.dart';

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

  void _openAddUserModal() {
    AdminUserFormDialog.show(
      context,
      onSave: ({
        required fullName,
        required email,
        required role,
        dateOfBirth,
        fatherName,
        fatherMobile,
        currentAddress,
        department,
        enrollmentNumber,
        employeeId,
        course,
        branch,
        admissionDate,
        registrationDate,
        phone,
        designation,
        status,
      }) async {
        return await context.read<AdminUsersProvider>().addUser(
          fullName: fullName,
          email: email,
          role: role,
          dateOfBirth: dateOfBirth,
          fatherName: fatherName,
          fatherMobile: fatherMobile,
          currentAddress: currentAddress,
          department: department,
          enrollmentNumber: enrollmentNumber,
          employeeId: employeeId,
          course: course,
          branch: branch,
          admissionDate: admissionDate,
          registrationDate: registrationDate,
          phone: phone,
          designation: designation,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminUsersProvider>();
    final isEditor = context.watch<AdminAuthProvider>().isEditor;
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

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
          // Section Heading with Text-First Add User Button
          AdminSectionHeader(
            title: 'User Management',
            padding: const EdgeInsets.only(bottom: 16),
            trailing: isEditor
                ? ElevatedButton(
                    onPressed: _openAddUserModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.brand,
                      foregroundColor: isDark ? AppColors.brand : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Add User'),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AdminFilterChips(
                        filters: const ['all', 'active', 'suspended', 'student', 'faculty'],
                        selected: _filter,
                        onSelected: (f) => setState(() => _filter = f),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      hint: 'Search by name, email, enrollment, or phone...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildDesktopFilters(isDark, provider),
                  const SizedBox(width: 12),
                  AdminFilterChips(
                    filters: const ['all', 'active', 'suspended', 'student', 'faculty'],
                    selected: _filter,
                    onSelected: (f) => setState(() => _filter = f),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // User Table Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (provider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.text(isDark)),
                      ),
                    ),
                  );
                }

                if (filteredUsers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(60),
                    child: Center(
                      child: Text(
                        'No user accounts match the current filters.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSec(isDark),
                        ),
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
    final borderColor = AppColors.border(isDark);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 12, color: AppColors.textMut(isDark))),
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.text(isDark)),
          dropdownColor: AppColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(4),
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
    final borderColor = AppColors.border(isDark);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: TextButton(
        onPressed: () => _showMobileFilterBottomSheet(isDark, provider),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text('Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
      ),
    );
  }

  void _showMobileFilterBottomSheet(bool isDark, AdminUsersProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(isDark),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Filter Records', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      provider.clearAllFilters();
                      Navigator.pop(ctx);
                    },
                    child: Text('Reset', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Course', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
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
              Text('Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
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
                    backgroundColor: isDark ? Colors.white : AppColors.brand,
                    foregroundColor: isDark ? AppColors.brand : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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

  Widget _buildDesktopTable(List<ManagedUser> users, bool isDark, bool isEditor, Color borderColor) {
    final headerBg = AppColors.surfaceAlt(isDark);
    final headerText = AppColors.textSec(isDark);
    final rowDivider = AppColors.borderSubtle(isDark);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
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
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text(isDark),
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text(isDark),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textMut(isDark),
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
                              color: AppColors.text(isDark),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            user.branch != null ? '${user.course ?? ""} - ${user.branch}' : (user.department ?? '—'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSec(isDark),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user.role,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSec(isDark),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AdminStatusBadge(status: user.status),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              '${user.postsCount}',
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
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildTextActionBtn(
                                  label: 'View',
                                  onTap: () async {
                                    await context.read<AdminUsersProvider>().selectUser(user.id);
                                    setState(() => _showingDetail = true);
                                  },
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                                _buildTextActionBtn(
                                  label: isUserActive ? 'Suspend' : 'Activate',
                                  onTap: () => _handleUserStatus(user),
                                  isDanger: isUserActive,
                                  isDark: isDark,
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

  Widget _buildMobileCards(List<ManagedUser> users, bool isDark, bool isEditor) {
    final borderColor = AppColors.border(isDark);
    return Column(
      children: users.map((user) {
        return InkWell(
          onTap: () async {
            await context.read<AdminUsersProvider>().selectUser(user.id);
            setState(() => _showingDetail = true);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.surfaceAlt(isDark),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(isDark),
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
                              color: AppColors.text(isDark),
                            ),
                          ),
                          Text(
                            user.enrollmentNumber ?? user.employeeId ?? user.email,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMut(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AdminStatusBadge(status: user.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMobileTag(isDark, user.role),
                    const SizedBox(width: 6),
                    if (user.branch != null) _buildMobileTag(isDark, user.branch!),
                    const Spacer(),
                    Text(
                      '${user.postsCount} posts',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark)),
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
    final borderColor = AppColors.border(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt(isDark),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSec(isDark),
        ),
      ),
    );
  }

  void _handleUserStatus(ManagedUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    if (user.status == 'active') {
      final reasonCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Text(
            'Suspend User Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.text(isDark),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suspend access for ${user.fullName} (${user.email}). Provide an administrative reason:',
                style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                decoration: InputDecoration(
                  hintText: 'e.g. Violation of academic policy...',
                  hintStyle: TextStyle(color: AppColors.textMut(isDark), fontSize: 12.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              ),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonCtrl.text.trim().isEmpty ? 'Administrative action' : reasonCtrl.text.trim();
                final admin = context.read<AdminAuthProvider>().currentAdmin;
                context.read<AdminUsersProvider>().suspendUser(user.id, reason, admin?.name ?? 'Admin');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              ),
              child: const Text('Suspend User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      );
    } else {
      final admin = context.read<AdminAuthProvider>().currentAdmin;
      context.read<AdminUsersProvider>().restoreUser(user.id, admin?.name ?? 'Admin');
    }
  }
}