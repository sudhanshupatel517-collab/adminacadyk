import 'admin_models.dart';
import 'admin_mock_data.dart';

/// Admin Service Layer
/// Currently uses mock data. Replace with real API calls later:
/// UI -> Provider -> AdminService -> ApiClient -> Backend
class AdminService {
  // â”€â”€ Authentication â”€â”€
  static AdminAccount? authenticate(String email, String password) {
    for (int i = 0; i < AdminMockData.adminAccounts.length; i++) {
      if (AdminMockData.adminAccounts[i].email.toLowerCase() == email.toLowerCase() &&
          AdminMockData.adminPasswords[i] == password) {
        return AdminMockData.adminAccounts[i];
      }
    }
    return null;
  }

  // â”€â”€ Dashboard â”€â”€
  static Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AdminMockData.dashboardStats;
  }

  // â”€â”€ Users â”€â”€
  static Future<List<ManagedUser>> getUsers({String? search, String? statusFilter, String? roleFilter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var users = List<ManagedUser>.from(AdminMockData.users);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      users = users.where((u) =>
        u.fullName.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q)
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

  static Future<void> updateUserStatus(String userId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(status: newStatus);
    }
  }

  // â”€â”€ Content â”€â”€
  static Future<List<ManagedContent>> getContent({String? search, String? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = AdminMockData.content.indexWhere((c) => c.id == contentId);
    if (idx != -1) {
      AdminMockData.content[idx] = AdminMockData.content[idx].copyWith(status: newStatus);
    }
  }

  // â”€â”€ Activity Log â”€â”€
  static Future<List<ActivityLogEntry>> getActivityLog() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return AdminMockData.activityLog;
  }

  // â”€â”€ Settings â”€â”€
  static AppSettingsModel _settings = AdminMockData.defaultSettings;

  static Future<AppSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _settings;
  }

  static Future<void> saveSettings(AppSettingsModel settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = settings;
  }
}