import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_responsive.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _filter = 'all';

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
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    final filteredUsers = provider.users.where((u) {
      if (_filter == 'all') return true;
      if (_filter == 'active') return u.status == 'active';
      if (_filter == 'suspended') return u.status == 'suspended';
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
                    AdminSearchBar(
                      hint: 'Search users by name or email...',
                      onChanged: (q) => provider.setSearch(q),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChips(isDark),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: AdminSearchBar(
                    hint: 'Search users by name or email...',
                    onChanged: (q) => provider.setSearch(q),
                  )),
                  const SizedBox(width: 16),
                  _buildFilterChips(isDark),
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
                  return _buildMobileCards(filteredUsers, isDark);
                }
                return _buildDesktopTable(filteredUsers, isDark, borderColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = ['all', 'active', 'suspended'];
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    fontSize: 13, fontWeight: FontWeight.w600,
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

  Widget _buildDesktopTable(List<dynamic> users, bool isDark, Color borderColor) {
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
              Expanded(flex: 3, child: Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 2, child: Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3))),
              Expanded(flex: 1, child: Center(child: Text('Posts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: headerText, letterSpacing: 0.3)))),
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
                  onTap: () {},
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
                            Expanded(child: Text(user.fullName, style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ), overflow: TextOverflow.ellipsis)),
                          ],
                        )),
                        Expanded(flex: 3, child: Text(user.email, style: TextStyle(
                          fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                        ), overflow: TextOverflow.ellipsis)),
                        Expanded(flex: 2, child: Container(
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
                        Expanded(flex: 2, child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionBtn(isDark, Icons.edit_outlined, 'Edit', () {}),
                            const SizedBox(width: 6),
                            _buildActionBtn(isDark,
                              isUserActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                              isUserActive ? 'Suspend' : 'Activate',
                              () {
                                context.read<AdminUsersProvider>().toggleUserStatus(user.id, user.status);
                              },
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

  Widget _buildMobileCards(List<dynamic> users, bool isDark) {
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    return Column(
      children: users.map((user) {
        final isUserActive = user.status == 'active';
        return Container(
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
                      Text(user.email, style: TextStyle(
                        fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
                      )),
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
                  if (user.department != null) _buildMobileTag(isDark, user.department!),
                  const Spacer(),
                  Text('${user.postsCount} posts', style: TextStyle(
                    fontSize: 12, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AdminUsersProvider>().toggleUserStatus(user.id, user.status);
                  },
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
}