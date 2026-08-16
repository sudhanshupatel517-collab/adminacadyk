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

  static int _userIdCounter = 20;
  static int _contentIdCounter = 20;
  static int _activityIdCounter = 20;

  static String nextUserId() => 'u-${++_userIdCounter}';
  static String nextContentId() => 'p-${++_contentIdCounter}';
  static String nextActivityId() => 'a-${++_activityIdCounter}';

  static final List<ManagedUser> users = [
    ManagedUser(id: 'u-1', fullName: 'Sudhanshu Patel', email: 'sudhanshu@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science', joinedAt: DateTime(2024, 3, 15), lastActive: DateTime.now(), postsCount: 12),
    ManagedUser(id: 'u-2', fullName: 'Aarav Sharma', email: 'aarav@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science', joinedAt: DateTime(2024, 1, 10), lastActive: DateTime.now().subtract(const Duration(hours: 2)), postsCount: 28),
    ManagedUser(id: 'u-3', fullName: 'Ananya Roy', email: 'ananya@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Information Technology', joinedAt: DateTime(2024, 2, 20), lastActive: DateTime.now().subtract(const Duration(days: 1)), postsCount: 14),
    ManagedUser(id: 'u-4', fullName: 'Dr. Rajesh Verma', email: 'rajesh.verma@acadyk.edu', role: 'FACULTY', status: 'active', department: 'Computer Science', joinedAt: DateTime(2023, 8, 1), lastActive: DateTime.now().subtract(const Duration(hours: 5)), postsCount: 42),
    ManagedUser(id: 'u-5', fullName: 'Priya Nair', email: 'priya@acadyk.edu', role: 'STUDENT', status: 'suspended', department: 'Electronics', joinedAt: DateTime(2024, 6, 1), lastActive: DateTime.now().subtract(const Duration(days: 14)), postsCount: 3),
    ManagedUser(id: 'u-6', fullName: 'Siddharth Mehta', email: 'siddharth@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Mechanical Engineering', joinedAt: DateTime(2024, 4, 10), lastActive: DateTime.now().subtract(const Duration(days: 3)), postsCount: 8),
    ManagedUser(id: 'u-7', fullName: 'Kavya Iyer', email: 'kavya@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science', joinedAt: DateTime(2024, 7, 5), lastActive: DateTime.now().subtract(const Duration(hours: 1)), postsCount: 19),
    ManagedUser(id: 'u-8', fullName: 'Rohit Desai', email: 'rohit@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Civil Engineering', joinedAt: DateTime(2024, 5, 12), lastActive: DateTime.now().subtract(const Duration(days: 7)), postsCount: 5),
    ManagedUser(id: 'u-9', fullName: 'Dr. Meera Joshi', email: 'meera.joshi@acadyk.edu', role: 'FACULTY', status: 'active', department: 'Information Technology', joinedAt: DateTime(2023, 6, 15), lastActive: DateTime.now().subtract(const Duration(hours: 8)), postsCount: 31),
    ManagedUser(id: 'u-10', fullName: 'Vikram Singh', email: 'vikram@acadyk.edu', role: 'STUDENT', status: 'banned', department: 'Electronics', joinedAt: DateTime(2024, 1, 22), lastActive: DateTime.now().subtract(const Duration(days: 30)), postsCount: 1),
    ManagedUser(id: 'u-11', fullName: 'Neha Gupta', email: 'neha@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science', joinedAt: DateTime(2024, 8, 1), lastActive: DateTime.now(), postsCount: 2),
    ManagedUser(id: 'u-12', fullName: 'Arjun Kapoor', email: 'arjun@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Mechanical Engineering', joinedAt: DateTime(2024, 3, 28), lastActive: DateTime.now().subtract(const Duration(days: 2)), postsCount: 11),
  ];

  static final List<ManagedContent> content = [
    ManagedContent(id: 'p-1', authorName: 'Aarav Sharma', authorEmail: 'aarav@acadyk.edu', content: 'Our research paper on Optimizing Transformer Models for Edge Devices has been accepted at IEEE ICML 2026. Grateful to Dr. Verma for the mentorship.', postType: 'research', status: 'published', likeCount: 142, commentCount: 28, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ManagedContent(id: 'p-2', authorName: 'Ananya Roy', authorEmail: 'ananya@acadyk.edu', content: 'Annual Campus Startup Demo Day is officially live. Over 20 student-led startups presenting their work today in the main auditorium.', postType: 'announcement', status: 'published', likeCount: 89, commentCount: 14, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ManagedContent(id: 'p-3', authorName: 'Dr. Rajesh Verma', authorEmail: 'rajesh.verma@acadyk.edu', content: 'Applications open for the Autumn 2026 Undergraduate Research Fellowship. Monthly stipend of Rs 12,000. Apply by September 15.', postType: 'opportunity', status: 'published', likeCount: 215, commentCount: 42, reportCount: 0, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ManagedContent(id: 'p-4', authorName: 'Unknown User', authorEmail: 'spam@external.com', content: 'Buy cheap followers and likes! Visit our site now for amazing deals on social media growth and assignments...', postType: 'text', status: 'flagged', likeCount: 1, commentCount: 0, reportCount: 12, createdAt: DateTime.now().subtract(const Duration(hours: 8))),
    ManagedContent(id: 'p-5', authorName: 'Kavya Iyer', authorEmail: 'kavya@acadyk.edu', content: 'Just completed the AWS Cloud Practitioner certification. Here are my study notes and resources for anyone preparing.', postType: 'text', status: 'published', likeCount: 67, commentCount: 9, createdAt: DateTime.now().subtract(const Duration(hours: 12))),
    ManagedContent(id: 'p-6', authorName: 'Siddharth Mehta', authorEmail: 'siddharth@acadyk.edu', content: 'Looking for teammates for Smart India Hackathon 2026. Need 2 developers and 1 designer. DM if interested.', postType: 'text', status: 'published', likeCount: 34, commentCount: 18, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ManagedContent(id: 'p-7', authorName: 'Rohit Desai', authorEmail: 'rohit@acadyk.edu', content: 'Campus WiFi has been completely unstable in Block C for 3 days. Hope administration fixes it soon.', postType: 'text', status: 'flagged', likeCount: 24, commentCount: 5, reportCount: 2, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  static final List<ActivityLogEntry> activityLog = [
    ActivityLogEntry(id: 'a-1', action: 'User suspended', performedBy: 'Sudhanshu Patel', target: 'priya@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(hours: 1)), category: 'user'),
    ActivityLogEntry(id: 'a-2', action: 'Content flagged', performedBy: 'System', target: 'Post p-4', timestamp: DateTime.now().subtract(const Duration(hours: 3)), category: 'content'),
    ActivityLogEntry(id: 'a-3', action: 'Settings updated', performedBy: 'Sudhanshu Patel', target: 'Feature Flags', timestamp: DateTime.now().subtract(const Duration(hours: 6)), category: 'settings'),
    ActivityLogEntry(id: 'a-4', action: 'User role changed', performedBy: 'Sudhanshu Patel', target: 'ananya@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 1)), category: 'user'),
    ActivityLogEntry(id: 'a-5', action: 'New admin added', performedBy: 'Sudhanshu Patel', target: 'viewer@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 2)), category: 'user'),
    ActivityLogEntry(id: 'a-6', action: 'Content approved', performedBy: 'Ananya Roy', target: 'Post p-1', timestamp: DateTime.now().subtract(const Duration(days: 3)), category: 'content'),
    ActivityLogEntry(id: 'a-7', action: 'User registered', performedBy: 'System', target: 'neha@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(hours: 4)), category: 'user'),
    ActivityLogEntry(id: 'a-8', action: 'Content approved', performedBy: 'Ananya Roy', target: 'Post p-5', timestamp: DateTime.now().subtract(const Duration(hours: 7)), category: 'content'),
    ActivityLogEntry(id: 'a-9', action: 'Maintenance mode toggled', performedBy: 'Sudhanshu Patel', target: 'OFF', timestamp: DateTime.now().subtract(const Duration(days: 4)), category: 'settings'),
    ActivityLogEntry(id: 'a-10', action: 'User banned', performedBy: 'Sudhanshu Patel', target: 'vikram@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 5)), category: 'user'),
  ];

  static AppSettingsModel get defaultSettings => AppSettingsModel();
}