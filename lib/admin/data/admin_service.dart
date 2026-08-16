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
    return DashboardStats(
      totalUsers: users.length,
      activeUsers: users.where((u) => u.status == 'active').length,
      totalPosts: content.length,
      totalOpportunities: content.where((c) => c.postType == 'opportunity').length,
      totalClubs: 24,
      totalEvents: 18,
      pendingReports: content.where((c) => c.status == 'flagged').length,
      newUsersToday: users.where((u) => u.joinedAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length,
    );
  }

  // -- Users CRUD --
  static Future<List<ManagedUser>> getUsers({String? search, String? statusFilter, String? roleFilter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var users = List<ManagedUser>.from(AdminMockData.users);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      users = users.where((u) =>
        u.fullName.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.department?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      users = users.where((u) => u.status == statusFilter).toList();
    }
    if (roleFilter != null && roleFilter.isNotEmpty) {
      users = users.where((u) => u.role == roleFilter).toList();
    }
    return users;
  }

  static Future<void> addUser(ManagedUser user) async {
    await Future.delayed(const Duration(milliseconds: 150));
    AdminMockData.users.insert(0, user);
    _logActivity('User added', 'Sudhanshu Patel', user.email, 'user');
  }

  static Future<void> updateUser(String userId, {String? fullName, String? email, String? role, String? status, String? department}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final u = AdminMockData.users[idx];
      AdminMockData.users[idx] = u.copyWith(
        fullName: fullName, email: email, role: role,
        status: status, department: department,
      );
      _logActivity('User updated', 'Sudhanshu Patel', AdminMockData.users[idx].email, 'user');
    }
  }

  static Future<void> updateUserStatus(String userId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(status: newStatus);
      final action = newStatus == 'active' ? 'User activated' : newStatus == 'suspended' ? 'User suspended' : 'User banned';
      _logActivity(action, 'Sudhanshu Patel', AdminMockData.users[idx].email, 'user');
    }
  }

  static Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final user = AdminMockData.users.firstWhere((u) => u.id == userId);
    AdminMockData.users.removeWhere((u) => u.id == userId);
    _logActivity('User deleted', 'Sudhanshu Patel', user.email, 'user');
  }

  // -- Content CRUD --
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
      _logActivity(action, 'Sudhanshu Patel', 'Post ${AdminMockData.content[idx].id}', 'content');
    }
  }

  static Future<void> deleteContent(String contentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _logActivity('Content deleted', 'Sudhanshu Patel', 'Post $contentId', 'content');
    AdminMockData.content.removeWhere((c) => c.id == contentId);
  }

  // -- Activity Log --
  static Future<List<ActivityLogEntry>> getActivityLog({String? categoryFilter}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var log = List<ActivityLogEntry>.from(AdminMockData.activityLog);
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      log = log.where((e) => e.category == categoryFilter).toList();
    }
    log.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return log;
  }

  static void _logActivity(String action, String performedBy, String target, String category) {
    AdminMockData.activityLog.insert(0, ActivityLogEntry(
      id: AdminMockData.nextActivityId(),
      action: action,
      performedBy: performedBy,
      target: target,
      timestamp: DateTime.now(),
      category: category,
    ));
  }

  // -- Settings --
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

  // -- Export Helper --
  static String generateUsersCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Full Name,Email,Role,Status,Department,Posts Count,Joined Date');
    for (final u in AdminMockData.users) {
      buffer.writeln('${u.id},"${u.fullName}","${u.email}",${u.role},${u.status},"${u.department ?? ""}",${u.postsCount},${u.joinedAt.toIso8601String()}');
    }
    return buffer.toString();
  }
}