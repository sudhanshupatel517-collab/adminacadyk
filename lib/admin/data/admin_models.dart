// Acadyk Admin Panel — Data Models
// Architecture: UI -> Provider -> Service -> API/Mock

class AdminAccount {
  final String id;
  final String email;
  final String name;
  final String role; // SUPER_ADMIN, EDITOR, VIEWER
  final String? avatarUrl;

  AdminAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  factory AdminAccount.fromJson(Map<String, dynamic> json) {
    return AdminAccount(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'VIEWER',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'name': name,
    'role': role, 'avatarUrl': avatarUrl,
  };

  bool get isSuperAdmin => role == 'SUPER_ADMIN';
  bool get isEditor => role == 'EDITOR' || isSuperAdmin;
}

class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int totalPosts;
  final int totalOpportunities;
  final int totalClubs;
  final int totalEvents;
  final int pendingReports;
  final int newUsersToday;

  DashboardStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalPosts = 0,
    this.totalOpportunities = 0,
    this.totalClubs = 0,
    this.totalEvents = 0,
    this.pendingReports = 0,
    this.newUsersToday = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalPosts: json['totalPosts'] ?? 0,
      totalOpportunities: json['totalOpportunities'] ?? 0,
      totalClubs: json['totalClubs'] ?? 0,
      totalEvents: json['totalEvents'] ?? 0,
      pendingReports: json['pendingReports'] ?? 0,
      newUsersToday: json['newUsersToday'] ?? 0,
    );
  }
}

class ManagedUser {
  final String id;
  String fullName;
  String email;
  String role;
  String status; // active, suspended, banned
  String? department;
  final String? avatarUrl;
  final DateTime joinedAt;
  final DateTime lastActive;
  int postsCount;

  ManagedUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'STUDENT',
    this.status = 'active',
    this.department,
    this.avatarUrl,
    required this.joinedAt,
    required this.lastActive,
    this.postsCount = 0,
  });

  factory ManagedUser.fromJson(Map<String, dynamic> json) {
    return ManagedUser(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'STUDENT',
      status: json['status'] ?? 'active',
      department: json['department'],
      avatarUrl: json['avatarUrl'] ?? json['profilePhotoUrl'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : DateTime.now(),
      postsCount: json['postsCount'] ?? 0,
    );
  }

  ManagedUser copyWith({String? fullName, String? email, String? status, String? role, String? department}) {
    return ManagedUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      department: department ?? this.department,
      avatarUrl: avatarUrl,
      joinedAt: joinedAt,
      lastActive: lastActive,
      postsCount: postsCount,
    );
  }
}

class ManagedContent {
  final String id;
  final String authorName;
  final String authorEmail;
  final String content;
  final String postType;
  String status; // published, flagged, removed
  final int likeCount;
  final int commentCount;
  final int reportCount;
  final DateTime createdAt;
  final String? imageUrl;

  ManagedContent({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    this.postType = 'text',
    this.status = 'published',
    this.likeCount = 0,
    this.commentCount = 0,
    this.reportCount = 0,
    required this.createdAt,
    this.imageUrl,
  });

  factory ManagedContent.fromJson(Map<String, dynamic> json) {
    return ManagedContent(
      id: json['id'] ?? '',
      authorName: json['authorName'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
      content: json['content'] ?? '',
      postType: json['postType'] ?? 'text',
      status: json['status'] ?? 'published',
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  ManagedContent copyWith({String? status, int? reportCount}) {
    return ManagedContent(
      id: id,
      authorName: authorName,
      authorEmail: authorEmail,
      content: content,
      postType: postType,
      status: status ?? this.status,
      likeCount: likeCount,
      commentCount: commentCount,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt,
      imageUrl: imageUrl,
    );
  }
}

class ActivityLogEntry {
  final String id;
  final String action;
  final String performedBy;
  final String target;
  final DateTime timestamp;
  final String category; // user, content, settings, system

  ActivityLogEntry({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.target,
    required this.timestamp,
    this.category = 'system',
  });
}

class AppSettingsModel {
  String appName;
  String tagline;
  String contactEmail;
  bool maintenanceMode;
  bool enableAIRecommendations;
  bool enableRealtimeChat;
  bool enableStartups;
  bool enableLeaderboard;
  bool enableEvents;

  AppSettingsModel({
    this.appName = 'Acadyk',
    this.tagline = 'Academic Discovery & Career Network',
    this.contactEmail = 'support@acadyk.edu',
    this.maintenanceMode = false,
    this.enableAIRecommendations = false,
    this.enableRealtimeChat = true,
    this.enableStartups = true,
    this.enableLeaderboard = true,
    this.enableEvents = true,
  });

  AppSettingsModel copyWith({
    String? appName,
    String? tagline,
    String? contactEmail,
    bool? maintenanceMode,
    bool? enableAIRecommendations,
    bool? enableRealtimeChat,
    bool? enableStartups,
    bool? enableLeaderboard,
    bool? enableEvents,
  }) {
    return AppSettingsModel(
      appName: appName ?? this.appName,
      tagline: tagline ?? this.tagline,
      contactEmail: contactEmail ?? this.contactEmail,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      enableAIRecommendations: enableAIRecommendations ?? this.enableAIRecommendations,
      enableRealtimeChat: enableRealtimeChat ?? this.enableRealtimeChat,
      enableStartups: enableStartups ?? this.enableStartups,
      enableLeaderboard: enableLeaderboard ?? this.enableLeaderboard,
      enableEvents: enableEvents ?? this.enableEvents,
    );
  }
}