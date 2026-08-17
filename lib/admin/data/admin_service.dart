import 'admin_models.dart';
import 'admin_mock_data.dart';

/// Admin Service Layer
/// Provides complete CRUD methods with simulated network latency and real state updates.
class AdminService {
  // -- Authentication --
  static AdminAccount? authenticate(String email, String password) {
    for (int i = 0; i < AdminMockData.adminAccounts.length; i++) {
      if (AdminMockData.adminAccounts[i].email.toLowerCase() == email.toLowerCase() &&
          AdminMockData.adminPasswords[i] == password) {
        return AdminMockData.adminAccounts[i];
      }
    }
    return null;
  }

  // -- Dashboard --
  static Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final users = AdminMockData.users;
    final content = AdminMockData.content;
    final events = AdminMockData.events;
    final orgs = AdminMockData.organizations;
    final notices = AdminMockData.notices;
    return DashboardStats(
      totalUsers: users.length,
      activeUsers: users.where((u) => u.status == 'active').length,
      totalPosts: content.length,
      totalOpportunities: content.where((c) => c.postType == 'opportunity').length,
      totalClubs: orgs.where((o) => o.type == 'club').length,
      totalEvents: events.length,
      pendingReports: content.where((c) => c.status == 'flagged').length,
      newUsersToday: users.where((u) => u.joinedAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length,
      totalStudents: users.where((u) => u.role == 'STUDENT').length,
      totalFaculty: users.where((u) => u.role == 'FACULTY').length,
      totalOrganizations: orgs.length,
      totalNotices: notices.where((n) => n.status == 'published').length,
      suspendedUsers: users.where((u) => u.status == 'suspended').length,
    );
  }

  // ==================== USERS CRUD ====================
  static Future<List<ManagedUser>> getUsers({
    String? search,
    String? statusFilter,
    String? roleFilter,
    String? courseFilter,
    String? branchFilter,
    String? departmentFilter,
    String? clubFilter,
    String? teamFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var users = List<ManagedUser>.from(AdminMockData.users);

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      users = users.where((u) =>
        u.fullName.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.department?.toLowerCase().contains(q) ?? false) ||
        (u.enrollmentNumber?.toLowerCase().contains(q) ?? false) ||
        (u.employeeId?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      users = users.where((u) => u.status == statusFilter).toList();
    }
    if (roleFilter != null && roleFilter.isNotEmpty) {
      users = users.where((u) => u.role == roleFilter).toList();
    }
    if (courseFilter != null && courseFilter.isNotEmpty) {
      users = users.where((u) => u.course == courseFilter).toList();
    }
    if (branchFilter != null && branchFilter.isNotEmpty) {
      users = users.where((u) => u.branch == branchFilter).toList();
    }
    if (departmentFilter != null && departmentFilter.isNotEmpty) {
      users = users.where((u) => u.department == departmentFilter).toList();
    }
    if (clubFilter != null && clubFilter.isNotEmpty) {
      users = users.where((u) => u.clubIds.contains(clubFilter)).toList();
    }
    if (teamFilter != null && teamFilter.isNotEmpty) {
      users = users.where((u) => u.teamIds.contains(teamFilter)).toList();
    }
    return users;
  }

  static Future<ManagedUser?> searchByEnrollment(String enrollment) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final q = enrollment.toUpperCase();
    try {
      return AdminMockData.users.firstWhere((u) => u.enrollmentNumber?.toUpperCase() == q);
    } catch (_) {
      return null;
    }
  }

  static Future<ManagedUser?> searchByEmployeeId(String empId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final q = empId.toUpperCase();
    try {
      return AdminMockData.users.firstWhere((u) => u.employeeId?.toUpperCase() == q);
    } catch (_) {
      return null;
    }
  }

  static Future<ManagedUser?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return AdminMockData.users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> addUser(ManagedUser user) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Validate unique enrollment/employee ID
    if (user.enrollmentNumber != null) {
      final existing = AdminMockData.users.where((u) => u.enrollmentNumber == user.enrollmentNumber).toList();
      if (existing.isNotEmpty) throw Exception('Enrollment number already exists');
    }
    if (user.employeeId != null) {
      final existing = AdminMockData.users.where((u) => u.employeeId == user.employeeId).toList();
      if (existing.isNotEmpty) throw Exception('Employee ID already exists');
    }
    AdminMockData.users.insert(0, user);
    _logActivity('User added', 'Sudhanshu Patel', user.email, 'user', targetId: user.id);
  }

  static Future<void> updateUser(String userId, {String? fullName, String? email, String? role, String? status, String? department, String? course, String? branch, String? phone, String? designation}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final u = AdminMockData.users[idx];
      AdminMockData.users[idx] = u.copyWith(
        fullName: fullName, email: email, role: role,
        status: status, department: department,
        course: course, branch: branch, phone: phone, designation: designation,
      );
      _logActivity('User updated', 'Sudhanshu Patel', AdminMockData.users[idx].email, 'user', targetId: userId);
    }
  }

  static Future<void> suspendUser(String userId, String reason, String adminName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(
        status: 'suspended',
        suspensionReason: reason,
        suspendedAt: DateTime.now(),
        suspendedBy: adminName,
      );
      _logActivity('User suspended', adminName, AdminMockData.users[idx].email, 'user', reason: reason, targetId: userId);
    }
  }

  static Future<void> restoreUser(String userId, String adminName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(status: 'active');
      _logActivity('User restored', adminName, AdminMockData.users[idx].email, 'user', targetId: userId);
    }
  }

  static Future<void> updateUserStatus(String userId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(status: newStatus);
      final action = newStatus == 'active' ? 'User activated' : newStatus == 'suspended' ? 'User suspended' : 'User banned';
      _logActivity(action, 'Sudhanshu Patel', AdminMockData.users[idx].email, 'user', targetId: userId);
    }
  }

  static Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final user = AdminMockData.users.firstWhere((u) => u.id == userId);
    AdminMockData.users.removeWhere((u) => u.id == userId);
    _logActivity('User deleted', 'Sudhanshu Patel', user.email, 'user', targetId: userId);
  }

  // ==================== CONTENT CRUD ====================
  static Future<List<ManagedContent>> getContent({String? search, String? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var items = List<ManagedContent>.from(AdminMockData.content);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((c) =>
        c.content.toLowerCase().contains(q) ||
        c.authorName.toLowerCase().contains(q)
      ).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      items = items.where((c) => c.status == statusFilter).toList();
    }
    return items;
  }

  static Future<void> updateContentStatus(String contentId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.content.indexWhere((c) => c.id == contentId);
    if (idx != -1) {
      AdminMockData.content[idx] = AdminMockData.content[idx].copyWith(status: newStatus);
      final action = newStatus == 'published' ? 'Content approved' : newStatus == 'flagged' ? 'Content flagged' : 'Content removed';
      _logActivity(action, 'Sudhanshu Patel', 'Post ${AdminMockData.content[idx].id}', 'content', targetId: contentId);
    }
  }

  static Future<void> deleteContent(String contentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _logActivity('Content deleted', 'Sudhanshu Patel', 'Post $contentId', 'content', targetId: contentId);
    AdminMockData.content.removeWhere((c) => c.id == contentId);
  }

  // ==================== EVENTS CRUD ====================
  static Future<List<ManagedEvent>> getEvents({String? search, String? statusFilter, String? orgFilter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var items = List<ManagedEvent>.from(AdminMockData.events);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((e) =>
        e.title.toLowerCase().contains(q) ||
        e.organizer.toLowerCase().contains(q) ||
        e.venue.toLowerCase().contains(q)
      ).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      items = items.where((e) => e.status == statusFilter).toList();
    }
    if (orgFilter != null && orgFilter.isNotEmpty) {
      items = items.where((e) => e.organizationId == orgFilter).toList();
    }
    return items;
  }

  static Future<void> createEvent(ManagedEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));
    AdminMockData.events.insert(0, event);
    _logActivity('Event created', event.createdBy ?? 'Admin', event.title, 'event', targetId: event.id);
  }

  static Future<void> updateEvent(String eventId, {String? title, String? description, String? venue, String? organizer, String? organizationId, DateTime? startDate, DateTime? endDate, DateTime? registrationDeadline, String? contactInfo, String? status, String? visibility}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      AdminMockData.events[idx] = AdminMockData.events[idx].copyWith(
        title: title, description: description, venue: venue,
        organizer: organizer, organizationId: organizationId,
        startDate: startDate, endDate: endDate,
        registrationDeadline: registrationDeadline, contactInfo: contactInfo,
        status: status, visibility: visibility,
      );
      _logActivity('Event updated', 'Sudhanshu Patel', AdminMockData.events[idx].title, 'event', targetId: eventId);
    }
  }

  static Future<void> updateEventStatus(String eventId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      AdminMockData.events[idx] = AdminMockData.events[idx].copyWith(status: newStatus);
      _logActivity('Event $newStatus', 'Sudhanshu Patel', AdminMockData.events[idx].title, 'event', targetId: eventId);
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final event = AdminMockData.events.firstWhere((e) => e.id == eventId);
    AdminMockData.events.removeWhere((e) => e.id == eventId);
    _logActivity('Event deleted', 'Sudhanshu Patel', event.title, 'event', targetId: eventId);
  }

  // ==================== ORGANIZATIONS CRUD ====================
  static Future<List<Organization>> getOrganizations({String? search, String? typeFilter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var items = List<Organization>.from(AdminMockData.organizations);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((o) =>
        o.name.toLowerCase().contains(q) ||
        (o.description?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (typeFilter != null && typeFilter.isNotEmpty) {
      items = items.where((o) => o.type == typeFilter).toList();
    }
    return items;
  }

  static Future<void> createOrganization(Organization org) async {
    await Future.delayed(const Duration(milliseconds: 200));
    AdminMockData.organizations.insert(0, org);
    _logActivity('Organization created', 'Sudhanshu Patel', org.name, 'organization', targetId: org.id);
  }

  static Future<void> updateOrganization(String orgId, {String? name, String? description, String? status, String? type}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1) {
      AdminMockData.organizations[idx] = AdminMockData.organizations[idx].copyWith(
        name: name, description: description, status: status, type: type,
      );
      _logActivity('Organization updated', 'Sudhanshu Patel', AdminMockData.organizations[idx].name, 'organization', targetId: orgId);
    }
  }

  static Future<void> addOrgMember(String orgId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1 && !AdminMockData.organizations[idx].memberIds.contains(userId)) {
      AdminMockData.organizations[idx].memberIds.add(userId);
      // Also add to user's clubIds/teamIds
      final uIdx = AdminMockData.users.indexWhere((u) => u.id == userId);
      if (uIdx != -1) {
        if (AdminMockData.organizations[idx].isClub) {
          if (!AdminMockData.users[uIdx].clubIds.contains(orgId)) {
            AdminMockData.users[uIdx].clubIds.add(orgId);
          }
        } else {
          if (!AdminMockData.users[uIdx].teamIds.contains(orgId)) {
            AdminMockData.users[uIdx].teamIds.add(orgId);
          }
        }
      }
      _logActivity('Member added to organization', 'Sudhanshu Patel', AdminMockData.organizations[idx].name, 'organization', targetId: orgId);
    }
  }

  static Future<void> removeOrgMember(String orgId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1) {
      AdminMockData.organizations[idx].memberIds.remove(userId);
      final uIdx = AdminMockData.users.indexWhere((u) => u.id == userId);
      if (uIdx != -1) {
        AdminMockData.users[uIdx].clubIds.remove(orgId);
        AdminMockData.users[uIdx].teamIds.remove(orgId);
      }
      _logActivity('Member removed from organization', 'Sudhanshu Patel', AdminMockData.organizations[idx].name, 'organization', targetId: orgId);
    }
  }

  static Future<void> archiveOrganization(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1) {
      AdminMockData.organizations[idx] = AdminMockData.organizations[idx].copyWith(status: 'archived');
      _logActivity('Organization archived', 'Sudhanshu Patel', AdminMockData.organizations[idx].name, 'organization', targetId: orgId);
    }
  }

  // ==================== NOTICES CRUD ====================
  static Future<List<Notice>> getNotices({String? search, String? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var items = List<Notice>.from(AdminMockData.notices);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((n) =>
        n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q)
      ).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      items = items.where((n) => n.status == statusFilter).toList();
    }
    return items;
  }

  static Future<void> createNotice(Notice notice) async {
    await Future.delayed(const Duration(milliseconds: 200));
    AdminMockData.notices.insert(0, notice);
    _logActivity('Notice created', notice.authorName ?? 'Admin', notice.title, 'notice', targetId: notice.id);
  }

  static Future<void> updateNotice(String noticeId, {String? title, String? content, String? priority, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.notices.indexWhere((n) => n.id == noticeId);
    if (idx != -1) {
      AdminMockData.notices[idx] = AdminMockData.notices[idx].copyWith(
        title: title, content: content, priority: priority, status: status,
      );
      _logActivity('Notice updated', 'Sudhanshu Patel', AdminMockData.notices[idx].title, 'notice', targetId: noticeId);
    }
  }

  static Future<void> publishNotice(String noticeId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = AdminMockData.notices.indexWhere((n) => n.id == noticeId);
    if (idx != -1) {
      AdminMockData.notices[idx] = AdminMockData.notices[idx].copyWith(status: 'published');
      _logActivity('Notice published', 'Sudhanshu Patel', AdminMockData.notices[idx].title, 'notice', targetId: noticeId);
    }
  }

  static Future<void> deleteNotice(String noticeId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final notice = AdminMockData.notices.firstWhere((n) => n.id == noticeId);
    AdminMockData.notices.removeWhere((n) => n.id == noticeId);
    _logActivity('Notice deleted', 'Sudhanshu Patel', notice.title, 'notice', targetId: noticeId);
  }

  // ==================== RESULTS ====================
  static Future<StudentResult?> getStudentResults(String enrollmentNumber) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return AdminMockData.results.firstWhere((r) => r.enrollmentNumber == enrollmentNumber);
    } catch (_) {
      return null;
    }
  }

  // ==================== ACTIVITY LOG ====================
  static Future<List<ActivityLogEntry>> getActivityLog({String? categoryFilter}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var log = List<ActivityLogEntry>.from(AdminMockData.activityLog);
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      log = log.where((e) => e.category == categoryFilter).toList();
    }
    log.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return log;
  }

  static void _logActivity(String action, String performedBy, String target, String category, {String? reason, String? targetId}) {
    AdminMockData.activityLog.insert(0, ActivityLogEntry(
      id: AdminMockData.nextActivityId(),
      action: action,
      performedBy: performedBy,
      target: target,
      timestamp: DateTime.now(),
      category: category,
      reason: reason,
      targetId: targetId,
    ));
  }

  // ==================== SETTINGS ====================
  static AppSettingsModel _settings = AdminMockData.defaultSettings;

  static Future<AppSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _settings;
  }

  static Future<void> saveSettings(AppSettingsModel settings) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _settings = settings;
    _logActivity('Settings updated', 'Sudhanshu Patel', 'Application Settings', 'settings');
  }

  // ==================== EXPORT ====================
  static String generateUsersCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Full Name,Email,Role,Status,Department,Enrollment,Employee ID,Course,Branch,Posts Count,Joined Date');
    for (final u in AdminMockData.users) {
      buffer.writeln('${u.id},"${u.fullName}","${u.email}",${u.role},${u.status},"${u.department ?? ""}","${u.enrollmentNumber ?? ""}","${u.employeeId ?? ""}","${u.course ?? ""}","${u.branch ?? ""}",${u.postsCount},${u.joinedAt.toIso8601String()}');
    }
    return buffer.toString();
  }

  // ==================== HELPER: Get org name by ID ====================
  static String? getOrganizationName(String orgId) {
    try {
      return AdminMockData.organizations.firstWhere((o) => o.id == orgId).name;
    } catch (_) {
      return null;
    }
  }
}