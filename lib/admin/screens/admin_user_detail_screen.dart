import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_users_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../widgets/admin_responsive.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final VoidCallback onBack;
  const AdminUserDetailScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminUsersProvider>();
    final user = provider.selectedUser;
    final results = provider.selectedUserResults;
    final isEditor = context.watch<AdminAuthProvider>().isEditor;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No user selected.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onBack, child: const Text('Back to Users')),
          ],
        ),
      );
    }

    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    final isUserActive = user.status == 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button & header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
                tooltip: 'Back to Users',
              ),
              const SizedBox(width: 8),
              Text(
                'User Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              if (isEditor)
                OutlinedButton.icon(
                  icon: Icon(
                    isUserActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(isUserActive ? 'Suspend Account' : 'Reactivate Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isUserActive ? const Color(0xFFEF5350) : const Color(0xFF00BA7C),
                    side: BorderSide(color: isUserActive ? const Color(0xFFEF5350) : const Color(0xFF00BA7C)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: () => _handleStatusAction(context, user),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Overview Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUserActive
                                  ? (isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9))
                                  : (isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFCE4EC)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isUserActive
                                    ? (isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32))
                                    : (isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildTag(isDark, user.role),
                          if (user.enrollmentNumber != null)
                            _buildTag(isDark, 'Enrollment: ${user.enrollmentNumber!}'),
                          if (user.employeeId != null)
                            _buildTag(isDark, 'Employee ID: ${user.employeeId!}'),
                          if (user.course != null && user.branch != null)
                            _buildTag(isDark, '${user.course} - ${user.branch}'),
                          if (user.designation != null)
                            _buildTag(isDark, user.designation!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildAcademicInfo(isDark, user, cardBg, borderColor),
                          const SizedBox(height: 20),
                          if (results != null) ...[
                            _buildResultsCard(isDark, results, cardBg, borderColor),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildOrgsCard(isDark, user, cardBg, borderColor),
                          const SizedBox(height: 20),
                          if (user.isSuspended && user.suspensionReason != null)
                            _buildSuspensionAuditCard(isDark, user, cardBg, borderColor),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Mobile Layout
              return Column(
                children: [
                  _buildAcademicInfo(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 20),
                  if (results != null) ...[
                    _buildResultsCard(isDark, results, cardBg, borderColor),
                    const SizedBox(height: 20),
                  ],
                  _buildOrgsCard(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 20),
                  if (user.isSuspended && user.suspensionReason != null)
                    _buildSuspensionAuditCard(isDark, user, cardBg, borderColor),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(bool isDark, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _buildAcademicInfo(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.isStudent ? 'Academic & Personal Details' : 'Faculty Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(isDark, 'Department', user.department ?? 'Not assigned'),
          _infoRow(isDark, 'Course', user.course ?? '—'),
          _infoRow(isDark, 'Branch / Specialization', user.branch ?? '—'),
          if (user.year != null) _infoRow(isDark, 'Year / Semester', 'Year ${user.year} (Semester ${user.semester ?? 1})'),
          if (user.batch != null) _infoRow(isDark, 'Batch', user.batch!),
          if (user.phone != null) _infoRow(isDark, 'Phone', user.phone!),
          _infoRow(isDark, 'Joined Platform', '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}'),
          _infoRow(isDark, 'Total Posts Published', '${user.postsCount}'),
        ],
      ),
    );
  }

  Widget _buildResultsCard(bool isDark, StudentResult result, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Academic Results & Grades',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CGPA: ${result.cgpa.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.semesters.map((sem) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semester ${sem.semester} (SGPA: ${sem.sgpa.toStringAsFixed(2)})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 8),
                ...sem.subjects.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          sub.code,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${sub.credits} cr',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            sub.grade,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrgsCard(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    final clubNames = user.clubIds.map((id) => AdminService.getOrganizationName(id) ?? id).toList();
    final teamNames = user.teamIds.map((id) => AdminService.getOrganizationName(id) ?? id).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clubs & Teams Affiliations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'CLUBS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
          ),
          const SizedBox(height: 6),
          if (clubNames.isEmpty)
            Text('No club memberships', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA)))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: clubNames.map((name) => _buildTag(isDark, name)).toList(),
            ),
          const SizedBox(height: 16),
          Text(
            'TEAMS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
          ),
          const SizedBox(height: 6),
          if (teamNames.isEmpty)
            Text('No team memberships', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA)))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: teamNames.map((name) => _buildTag(isDark, name)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSuspensionAuditCard(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFEF5350)),
              const SizedBox(width: 8),
              Text(
                'Suspension Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Reason: ${user.suspensionReason}',
            style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444)),
          ),
          if (user.suspendedBy != null) ...[
            const SizedBox(height: 4),
            Text(
              'Suspended by: ${user.suspendedBy}',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)),
            ),
          ],
          if (user.suspendedAt != null) ...[
            const SizedBox(height: 2),
            Text(
              'Date: ${user.suspendedAt!.day}/${user.suspendedAt!.month}/${user.suspendedAt!.year}',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusAction(BuildContext context, ManagedUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSuspended = user.status == 'suspended';

    if (isSuspended) {
      // Reactivation confirmation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Reactivate Account',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            'Reactivate account for ${user.fullName} (${user.email})? The user will immediately regain platform access.',
            style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666), fontSize: 14),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666)))),
            ElevatedButton(
              onPressed: () {
                final admin = context.read<AdminAuthProvider>().currentAdmin;
                context.read<AdminUsersProvider>().restoreUser(user.id, admin?.name ?? 'Admin');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BA7C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reactivate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );
    } else {
      // Suspension dialog with reason field
      final reasonCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Suspend User Account',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suspend access for ${user.fullName} (${user.email}). Provide an audit reason:',
                style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666), fontSize: 14),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'e.g. Violation of academic guidelines...',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA), fontSize: 13),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Suspend Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );
    }
  }
}
