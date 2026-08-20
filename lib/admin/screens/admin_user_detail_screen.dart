import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/admin_users_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_section_header.dart';
import '../widgets/admin_user_form_dialog.dart';
import '../../app/theme/app_colors.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final VoidCallback onBack;
  const AdminUserDetailScreen({super.key, required this.onBack});

  static final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  void _openEditUserModal(BuildContext context, ManagedUser user) {
    AdminUserFormDialog.show(
      context,
      initialUser: user,
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
        return await context.read<AdminUsersProvider>().updateUser(
          user.id,
          fullName: fullName,
          email: email,
          role: role,
          status: status ?? user.status,
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
    final user = provider.selectedUser;
    final results = provider.selectedUserResults;
    final isEditor = context.watch<AdminAuthProvider>().isEditor;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No user record selected.', style: TextStyle(fontSize: 13, color: AppColors.textSec(isDark))),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Back to Directory'),
            ),
          ],
        ),
      );
    }

    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);
    final isUserActive = user.status == 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Navigation & Actions
          Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Back to Directory', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              if (isEditor) ...[
                OutlinedButton(
                  onPressed: () => _openEditUserModal(context, user),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Text('Edit Record', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text(isDark))),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _handleStatusAction(context, user),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isUserActive ? AppColors.error : AppColors.success,
                    side: BorderSide(
                      color: isUserActive
                          ? (isDark ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFFFECACA))
                          : (isDark ? AppColors.success.withValues(alpha: 0.4) : const Color(0xFFBBF7D0)),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Text(
                    isUserActive ? 'Suspend Account' : 'Reactivate Account',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Institutional Profile Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceAlt(isDark),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text(isDark),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(isDark),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AdminStatusBadge(status: user.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMut(isDark),
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
                          _buildPersonalAndAddressCard(isDark, user, cardBg, borderColor),
                          const SizedBox(height: 18),
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
                          _buildAccountAndRegistrationCard(isDark, user, cardBg, borderColor),
                          const SizedBox(height: 18),
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
                  _buildPersonalAndAddressCard(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 18),
                  _buildAcademicInfo(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 18),
                  if (results != null) ...[
                    _buildResultsCard(isDark, results, cardBg, borderColor),
                    const SizedBox(height: 18),
                  ],
                  _buildAccountAndRegistrationCard(isDark, user, cardBg, borderColor),
                  const SizedBox(height: 18),
                  _buildOrgsCard(isDark, user, cardBg, borderColor),
                  if (user.isSuspended && user.suspensionReason != null) ...[
                    const SizedBox(height: 18),
                    _buildSuspensionAuditCard(isDark, user, cardBg, borderColor),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(bool isDark, String text) {
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

  Widget _buildPersonalAndAddressCard(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    final dobStr = user.dateOfBirth != null ? _dateFormat.format(user.dateOfBirth!) : '—';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Personal & Residential Details',
            padding: EdgeInsets.only(bottom: 12),
          ),
          _infoRow(isDark, 'Full Name', user.fullName),
          _infoRow(isDark, 'Date of Birth', dobStr),
          _infoRow(isDark, "Father's Name", user.fatherName ?? '—'),
          _infoRow(isDark, "Father's Mobile Number", user.fatherMobile ?? '—'),
          _infoRow(isDark, 'Current Address', user.currentAddress ?? '—'),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    final admStr = user.admissionDate != null ? _dateFormat.format(user.admissionDate!) : '—';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(
            title: user.isStudent ? 'Academic & Admission Records' : 'Faculty & Department Records',
            padding: const EdgeInsets.only(bottom: 12),
          ),
          if (user.isStudent) ...[
            _infoRow(isDark, 'Enrollment Number', user.enrollmentNumber ?? '—'),
            _infoRow(isDark, 'Course Program', user.course ?? '—'),
            _infoRow(isDark, 'Branch / Specialization', user.branch ?? '—'),
            _infoRow(isDark, 'Department', user.department ?? 'Not assigned'),
            _infoRow(isDark, 'Date of Admission', admStr),
            if (user.year != null) _infoRow(isDark, 'Year / Semester', 'Year ${user.year} (Semester ${user.semester ?? 1})'),
            if (user.batch != null) _infoRow(isDark, 'Batch Period', user.batch!),
          ] else ...[
            _infoRow(isDark, 'Employee ID', user.employeeId ?? '—'),
            _infoRow(isDark, 'Academic Department', user.department ?? 'Not assigned'),
            _infoRow(isDark, 'Faculty Designation', user.designation ?? '—'),
            _infoRow(isDark, 'Date of Joining / Admission', admStr),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountAndRegistrationCard(bool isDark, ManagedUser user, Color cardBg, Color borderColor) {
    final regStr = user.registrationDate != null
        ? _dateFormat.format(user.registrationDate!)
        : _dateFormat.format(user.joinedAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Account & System Registration',
            padding: EdgeInsets.only(bottom: 12),
          ),
          _infoRow(isDark, 'Official Email', user.email),
          _infoRow(isDark, 'Contact Mobile', user.phone ?? '—'),
          _infoRow(isDark, 'Account Status', user.status.toUpperCase()),
          _infoRow(isDark, 'Registration Date', regStr),
          _infoRow(isDark, 'Total Published Posts', '${user.postsCount}'),
        ],
      ),
    );
  }

  Widget _buildResultsCard(bool isDark, StudentResult result, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(isDark),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceAlt(isDark) : AppColors.successBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? AppColors.border(isDark) : const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  'Cumulative GPA: ${result.cgpa.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF4ADE80) : AppColors.successText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                      color: AppColors.text(isDark),
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
                            color: AppColors.textMut(isDark),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.name,
                            style: TextStyle(fontSize: 12, color: AppColors.text(isDark)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${sub.credits} cr',
                          style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark)),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt(isDark),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            sub.grade,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.text(isDark)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Club & Team Affiliations',
            padding: EdgeInsets.only(bottom: 12),
          ),
          Text(
            'STUDENT CLUBS',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.textMut(isDark)),
          ),
          const SizedBox(height: 6),
          if (clubNames.isEmpty)
            Text('No active club memberships', style: TextStyle(fontSize: 12, color: AppColors.textMut(isDark)))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: clubNames.map((name) => _buildTag(isDark, name)).toList(),
            ),
          const SizedBox(height: 14),
          Text(
            'PROJECT TEAMS',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.textMut(isDark)),
          ),
          const SizedBox(height: 6),
          if (teamNames.isEmpty)
            Text('No project team memberships', style: TextStyle(fontSize: 12, color: AppColors.textMut(isDark)))
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceAlt(isDark) : AppColors.errorBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppColors.border(isDark) : const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Suspension Audit Details',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF87171) : AppColors.errorText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reason: ${user.suspensionReason}',
            style: TextStyle(fontSize: 12, color: AppColors.text(isDark)),
          ),
          if (user.suspendedBy != null) ...[
            const SizedBox(height: 4),
            Text(
              'Suspended by: ${user.suspendedBy}',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark)),
            ),
          ],
          if (user.suspendedAt != null) ...[
            const SizedBox(height: 2),
            Text(
              'Effective Date: ${user.suspendedAt!.day}/${user.suspendedAt!.month}/${user.suspendedAt!.year}',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(bool isDark, String label, String value) {
    final borderColor = AppColors.borderSubtle(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSec(isDark),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.text(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusAction(BuildContext context, ManagedUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);
    final isSuspended = user.status == 'suspended';

    if (isSuspended) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
          title: Text(
            'Reactivate Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.text(isDark),
            ),
          ),
          content: Text(
            'Reactivate access for ${user.fullName} (${user.email})? The user will immediately regain access to the portal.',
            style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5),
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
                final admin = context.read<AdminAuthProvider>().currentAdmin;
                context.read<AdminUsersProvider>().restoreUser(user.id, admin?.name ?? 'Admin');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Reactivate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      );
    } else {
      final reasonCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: borderColor, width: 1)),
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
                'Suspend access for ${user.fullName} (${user.email}). Provide an audit reason:',
                style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
                decoration: InputDecoration(
                  hintText: 'e.g. Violation of campus guidelines...',
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Suspend Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        ),
      );
    }
  }
}
