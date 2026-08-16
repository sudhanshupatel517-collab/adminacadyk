import 'admin_models.dart';

class AdminMockData {
  static final List<AdminAccount> adminAccounts = [
    AdminAccount(id: 'admin-1', email: 'admin@acadyk.edu', name: 'Sudhanshu Patel', role: 'SUPER_ADMIN'),
    AdminAccount(id: 'admin-2', email: 'editor@acadyk.edu', name: 'Ananya Roy', role: 'EDITOR'),
    AdminAccount(id: 'admin-3', email: 'viewer@acadyk.edu', name: 'Aarav Sharma', role: 'VIEWER'),
  ];

  static final List<String> adminPasswords = [
    'SuperAdmin2026!',
    'Editor2026!',
    'Viewer2026!',
  ];

  static DashboardStats get dashboardStats => DashboardStats(
    totalUsers: 1247,
    activeUsers: 843,
    totalPosts: 3892,
    totalOpportunities: 56,
    totalClubs: 24,
    totalEvents: 18,
    pendingReports: 7,
    newUsersToday: 23,
  );

  static final List<ManagedUser> users = [
    ManagedUser(
      id: 'u-1', fullName: 'Sudhanshu Patel', email: 'sudhanshu@acadyk.edu',
      role: 'STUDENT', status: 'active', department: 'Computer Science',
      joinedAt: DateTime(2024, 3, 15), lastActive: DateTime.now(), postsCount: 12,
    ),
    ManagedUser(
      id: 'u-2', fullName: 'Aarav Sharma', email: 'aarav@acadyk.edu',
      role: 'STUDENT', status: 'active', department: 'Computer Science',
      joinedAt: DateTime(2024, 1, 10), lastActive: DateTime.now().subtract(const Duration(hours: 2)), postsCount: 28,
    ),
    ManagedUser(
      id: 'u-3', fullName: 'Ananya Roy', email: 'ananya@acadyk.edu',
      role: 'STUDENT', status: 'active', department: 'Information Technology',
      joinedAt: DateTime(2024, 2, 20), lastActive: DateTime.now().subtract(const Duration(days: 1)), postsCount: 14,
    ),
    ManagedUser(
      id: 'u-4', fullName: 'Dr. Rajesh Verma', email: 'rajesh.verma@acadyk.edu',
      role: 'FACULTY', status: 'active', department: 'Computer Science',
      joinedAt: DateTime(2023, 8, 1), lastActive: DateTime.now().subtract(const Duration(hours: 5)), postsCount: 42,
    ),
    ManagedUser(
      id: 'u-5', fullName: 'Priya Nair', email: 'priya@acadyk.edu',
      role: 'STUDENT', status: 'suspended', department: 'Electronics',
      joinedAt: DateTime(2024, 6, 1), lastActive: DateTime.now().subtract(const Duration(days: 14)), postsCount: 3,
    ),
    ManagedUser(
      id: 'u-6', fullName: 'Siddharth Mehta', email: 'siddharth@acadyk.edu',
      role: 'STUDENT', status: 'active', department: 'Mechanical Engineering',
      joinedAt: DateTime(2024, 4, 10), lastActive: DateTime.now().subtract(const Duration(days: 3)), postsCount: 8,
    ),
  ];

  static final List<ManagedContent> content = [
    ManagedContent(
      id: 'p-1', authorName: 'Aarav Sharma', authorEmail: 'aarav@acadyk.edu',
      content: 'Thrilled to announce our research paper on Optimizing Transformer Models for Edge Devices has been accepted at IEEE!',
      postType: 'research', status: 'published', likeCount: 142, commentCount: 28,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ManagedContent(
      id: 'p-2', authorName: 'Ananya Roy', authorEmail: 'ananya@acadyk.edu',
      content: 'Annual Campus Startup Demo Day is officially live! Over 20 student-led startups presenting today.',
      postType: 'announcement', status: 'published', likeCount: 89, commentCount: 14,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ManagedContent(
      id: 'p-3', authorName: 'Dr. Rajesh Verma', authorEmail: 'rajesh.verma@acadyk.edu',
      content: 'Applications open for the Autumn 2026 Undergraduate Research Fellowship. Stipend of \$1,500/month.',
      postType: 'opportunity', status: 'published', likeCount: 215, commentCount: 42, reportCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ManagedContent(
      id: 'p-4', authorName: 'Unknown User', authorEmail: 'spam@external.com',
      content: 'Buy cheap followers and likes! Visit our site now for amazing deals...',
      postType: 'text', status: 'flagged', likeCount: 1, commentCount: 0, reportCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  static final List<ActivityLogEntry> activityLog = [
    ActivityLogEntry(id: 'a-1', action: 'User suspended', performedBy: 'Sudhanshu Patel', target: 'priya@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    ActivityLogEntry(id: 'a-2', action: 'Content flagged', performedBy: 'System', target: 'Post p-4', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    ActivityLogEntry(id: 'a-3', action: 'Settings updated', performedBy: 'Sudhanshu Patel', target: 'Feature Flags', timestamp: DateTime.now().subtract(const Duration(hours: 6))),
    ActivityLogEntry(id: 'a-4', action: 'User role changed', performedBy: 'Sudhanshu Patel', target: 'ananya@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 1))),
    ActivityLogEntry(id: 'a-5', action: 'New admin added', performedBy: 'Sudhanshu Patel', target: 'viewer@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 2))),
    ActivityLogEntry(id: 'a-6', action: 'Content removed', performedBy: 'Ananya Roy', target: 'Post p-9', timestamp: DateTime.now().subtract(const Duration(days: 3))),
  ];

  static AppSettingsModel get defaultSettings => AppSettingsModel();
}