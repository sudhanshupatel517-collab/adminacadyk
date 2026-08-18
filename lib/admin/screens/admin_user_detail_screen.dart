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
            const Text('No user record selected.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onBack, child: const Text('Back to User Directory')),
          ],
        ),
      );
    }

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final isUserActive = user.status == 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Users'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              if (isEditor)
                OutlinedButton.icon(
                  icon: Icon(
                    isUserActive ? Icons.block_outlined : Icons.check_circle_outline_rounded,
                    size: 15,
                  ),
                  label: Text(isUserActive ? 'Suspend User Access' : 'Reactivate User Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isUserActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    side: BorderSide(
                      color: isUserActive ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _handleStatusAction(context, user),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Overview Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
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
          const SizedBox(height: 18),

          // Details Grid
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
                          const SizedBox(height: 18),
                          if (results != null) ...[
                            _buildResultsCard(isDark, results, cardBg, borderColor),
                            const SizedBox(height: 18),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildOrgsCard(isDark, user, cardBg, borderColor),
                          const SizedBox(height: 18),
                          if (user.isSuspended && user.suspensionReason != null)
                            _buildSuspensionAuditCard(isDark, user, cardBg, borderColor),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildAcademicInfo(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 18),
                  if (results != null) ...[
                    _buildResultsCard(isDark, results, cardBg, borderColor),
                    const SizedBox(height: 18),
                  ],
                  _buildOrgsCard(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 18),
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

  Widget _buildAcademicInfo(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.isStudent ? 'Academic & Personal Details' : 'Faculty & Department Records',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(isDark, 'Department', user.department ?? 'Not assigned'),
          _infoRow(isDark, 'Course', user.course ?? '—'),
          _infoRow(isDark, 'Branch / Specialization', user.branch ?? '—'),
          if (user.year != null) _infoRow(isDark, 'Year / Semester', 'Year ${user.year} (Semester ${user.semester ?? 1})'),
          if (user.batch != null) _infoRow(isDark, 'Batch', user.batch!),
          if (user.phone != null) _infoRow(isDark, 'Contact Phone', user.phone!),
          _infoRow(isDark, 'Registration Date', '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}'),
          _infoRow(isDark, 'Total Submissions / Posts', '${user.postsCount}'),
        ],
      ),
    );
  }

  Widget _buildResultsCard(bool isDark, StudentResult result, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Academic Results & Grades',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  'Cumulative GPA: ${result.cgpa.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.semesters.map((sem) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Semester ${sem.semester} (SGPA: ${sem.sgpa.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...sem.subjects.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          sub.code,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.name,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${sub.credits} cr',
                          style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            sub.grade,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Club & Team Affiliations',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'STUDENT CLUBS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          if (clubNames.isEmpty)
            Text('No active club memberships', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: clubNames.map((name) => _buildTag(isDark, name)).toList(),
            ),
          const SizedBox(height: 16),
          Text(
            'PROJECT TEAMS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          if (teamNames.isEmpty)
            Text('No project team memberships', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)))
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Text(
                'Account Suspension Audit Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Reason: ${user.suspensionReason}',
            style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
          ),
          if (user.suspendedBy != null) ...[
            const SizedBox(height: 4),
            Text(
              'Suspended by: ${user.suspendedBy}',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
          if (user.suspendedAt != null) ...[
            const SizedBox(height: 2),
            Text(
              'Effective Date: ${user.suspendedAt!.day}/${user.suspendedAt!.month}/${user.suspendedAt!.year}',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(bool isDark, String label, String value) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusAction(BuildContext context, ManagedUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final isSuspended = user.status == 'suspended';

    if (isSuspended) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: borderColor, width: 1)),
          title: Text(
            'Reactivate Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Reactivate access for ${user.fullName} (${user.email})? The user will immediately regain access to the portal.',
            style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13))),
            ElevatedButton(
              onPressed: () {
                final admin = context.read<AdminAuthProvider>().currentAdmin;
                context.read<AdminUsersProvider>().restoreUser(user.id, admin?.name ?? 'Admin');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Reactivate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );
    } else {
      final reasonCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: borderColor, width: 1)),
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
                  hintText: 'e.g. Violation of campus guidelines...',
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13))),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Suspend Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      );
    }
  }
}
