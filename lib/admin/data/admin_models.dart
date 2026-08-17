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
  final int totalStudents;
  final int totalFaculty;
  final int totalOrganizations;
  final int totalNotices;
  final int suspendedUsers;

  DashboardStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalPosts = 0,
    this.totalOpportunities = 0,
    this.totalClubs = 0,
    this.totalEvents = 0,
    this.pendingReports = 0,
    this.newUsersToday = 0,
    this.totalStudents = 0,
    this.totalFaculty = 0,
    this.totalOrganizations = 0,
    this.totalNotices = 0,
    this.suspendedUsers = 0,
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
      totalStudents: json['totalStudents'] ?? 0,
      totalFaculty: json['totalFaculty'] ?? 0,
      totalOrganizations: json['totalOrganizations'] ?? 0,
      totalNotices: json['totalNotices'] ?? 0,
      suspendedUsers: json['suspendedUsers'] ?? 0,
    );
  }
}

class ManagedUser {
  final String id;
  String fullName;
  String email;
  String role; // STUDENT, FACULTY, ADMIN
  String status; // active, suspended, banned
  String? department;
  final String? avatarUrl;
  final DateTime joinedAt;
  final DateTime lastActive;
  int postsCount;

  // Institutional fields
  String? enrollmentNumber; // e.g. BTAM25O1062
  String? employeeId; // e.g. EMP1025
  String? course; // e.g. B.Tech
  String? branch; // e.g. AIML, CSE, ECE
  int? year;
  int? semester;
  String? batch; // e.g. 2025-2029
  String? phone;
  String? designation; // for faculty
  List<String> clubIds;
  List<String> teamIds;
  List<String> eventIds; // registered events

  // Suspension audit
  String? suspensionReason;
  DateTime? suspendedAt;
  String? suspendedBy;

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
    this.enrollmentNumber,
    this.employeeId,
    this.course,
    this.branch,
    this.year,
    this.semester,
    this.batch,
    this.phone,
    this.designation,
    List<String>? clubIds,
    List<String>? teamIds,
    List<String>? eventIds,
    this.suspensionReason,
    this.suspendedAt,
    this.suspendedBy,
  })  : clubIds = clubIds ?? [],
        teamIds = teamIds ?? [],
        eventIds = eventIds ?? [];

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
      enrollmentNumber: json['enrollmentNumber'],
      employeeId: json['employeeId'],
      course: json['course'],
      branch: json['branch'],
      year: json['year'],
      semester: json['semester'],
      batch: json['batch'],
      phone: json['phone'],
      designation: json['designation'],
      clubIds: List<String>.from(json['clubIds'] ?? []),
      teamIds: List<String>.from(json['teamIds'] ?? []),
      eventIds: List<String>.from(json['eventIds'] ?? []),
      suspensionReason: json['suspensionReason'],
      suspendedAt: json['suspendedAt'] != null ? DateTime.parse(json['suspendedAt']) : null,
      suspendedBy: json['suspendedBy'],
    );
  }

  ManagedUser copyWith({
    String? fullName,
    String? email,
    String? status,
    String? role,
    String? department,
    String? enrollmentNumber,
    String? employeeId,
    String? course,
    String? branch,
    int? year,
    int? semester,
    String? batch,
    String? phone,
    String? designation,
    List<String>? clubIds,
    List<String>? teamIds,
    List<String>? eventIds,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? suspendedBy,
  }) {
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
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      employeeId: employeeId ?? this.employeeId,
      course: course ?? this.course,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      batch: batch ?? this.batch,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      clubIds: clubIds ?? this.clubIds,
      teamIds: teamIds ?? this.teamIds,
      eventIds: eventIds ?? this.eventIds,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspendedBy: suspendedBy ?? this.suspendedBy,
    );
  }

  bool get isStudent => role == 'STUDENT';
  bool get isFaculty => role == 'FACULTY';
  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
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
  final String? organizationId; // linked org

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
    this.organizationId,
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
      organizationId: json['organizationId'],
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
      organizationId: organizationId,
    );
  }
}

class ManagedEvent {
  final String id;
  String title;
  String description;
  String? posterUrl;
  DateTime? startDate;
  DateTime? endDate;
  String venue;
  String organizer;
  String? organizationId;
  String? contactInfo;
  DateTime? registrationDeadline;
  String status; // draft, scheduled, published, cancelled, completed
  String visibility; // public, private
  int registrationsCount;
  final DateTime createdAt;
  String? createdBy;

  ManagedEvent({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.startDate,
    this.endDate,
    this.venue = '',
    this.organizer = '',
    this.organizationId,
    this.contactInfo,
    this.registrationDeadline,
    this.status = 'draft',
    this.visibility = 'public',
    this.registrationsCount = 0,
    required this.createdAt,
    this.createdBy,
  });

  ManagedEvent copyWith({
    String? title,
    String? description,
    String? posterUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? organizer,
    String? organizationId,
    String? contactInfo,
    DateTime? registrationDeadline,
    String? status,
    String? visibility,
    int? registrationsCount,
    String? createdBy,
  }) {
    return ManagedEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      organizer: organizer ?? this.organizer,
      organizationId: organizationId ?? this.organizationId,
      contactInfo: contactInfo ?? this.contactInfo,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      registrationsCount: registrationsCount ?? this.registrationsCount,
      createdAt: createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isDraft => status == 'draft';
  bool get isPublished => status == 'published';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}

class Organization {
  final String id;
  String name;
  String type; // club, team
  String? description;
  String? logoUrl;
  String status; // active, archived
  List<String> memberIds;
  List<String> eventIds;
  String? department;
  String? facultyAdvisorId;
  final DateTime createdAt;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.logoUrl,
    this.status = 'active',
    List<String>? memberIds,
    List<String>? eventIds,
    this.department,
    this.facultyAdvisorId,
    required this.createdAt,
  })  : memberIds = memberIds ?? [],
        eventIds = eventIds ?? [];

  Organization copyWith({
    String? name,
    String? type,
    String? description,
    String? logoUrl,
    String? status,
    List<String>? memberIds,
    List<String>? eventIds,
    String? department,
    String? facultyAdvisorId,
  }) {
    return Organization(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      memberIds: memberIds ?? this.memberIds,
      eventIds: eventIds ?? this.eventIds,
      department: department ?? this.department,
      facultyAdvisorId: facultyAdvisorId ?? this.facultyAdvisorId,
      createdAt: createdAt,
    );
  }

  bool get isClub => type == 'club';
  bool get isTeam => type == 'team';
  bool get isActive => status == 'active';
}

class Notice {
  final String id;
  String title;
  String content;
  String priority; // normal, important, urgent
  String status; // draft, published, archived
  String? authorName;
  String? organizationId;
  DateTime? scheduledAt;
  final DateTime createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    this.priority = 'normal',
    this.status = 'draft',
    this.authorName,
    this.organizationId,
    this.scheduledAt,
    required this.createdAt,
  });

  Notice copyWith({
    String? title,
    String? content,
    String? priority,
    String? status,
    String? authorName,
    String? organizationId,
    DateTime? scheduledAt,
  }) {
    return Notice(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      authorName: authorName ?? this.authorName,
      organizationId: organizationId ?? this.organizationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt,
    );
  }
}

class SemesterResult {
  final String id;
  final int semester;
  final double sgpa;
  final int totalCredits;
  final List<SubjectResult> subjects;

  SemesterResult({
    required this.id,
    required this.semester,
    required this.sgpa,
    required this.totalCredits,
    required this.subjects,
  });
}

class SubjectResult {
  final String code;
  final String name;
  final int credits;
  final String grade;
  final double gradePoint;

  SubjectResult({
    required this.code,
    required this.name,
    required this.credits,
    required this.grade,
    required this.gradePoint,
  });
}

class StudentResult {
  final String enrollmentNumber;
  final List<SemesterResult> semesters;
  final double cgpa;

  StudentResult({
    required this.enrollmentNumber,
    required this.semesters,
    required this.cgpa,
  });
}

class ActivityLogEntry {
  final String id;
  final String action;
  final String performedBy;
  final String target;
  final DateTime timestamp;
  final String category; // user, content, settings, system, event, organization, notice
  final String? reason;
  final String? targetId;

  ActivityLogEntry({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.target,
    required this.timestamp,
    this.category = 'system',
    this.reason,
    this.targetId,
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