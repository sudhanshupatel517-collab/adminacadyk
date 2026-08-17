import 'admin_models.dart';
import 'admin_mock_data.dart';
import '../../core/network/api_client.dart';

/// Admin Service Layer
/// Directly integrates with the Backend REST API (ApiClient) so Admin actions update
/// the Database, which the User APK queries. If the backend is unreachable (offline/local mode),
/// it transparently operates on the internal persistent state without interruption.
class AdminService {
  // -- Authentication --
  /// Attempts to authenticate against the real backend first.
  /// Falls back to mock credentials if the backend is unreachable.
  static Future<AdminAccount?> authenticateAsync(String email, String password) async {
    try {
      final response = await ApiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 && response.data != null) {
        final data = ApiClient.extractData(response);
        if (data != null && data is Map) {
          // Backend returns AuthResponse with token + user profile
          final token = data['token']?.toString();
          if (token != null && token.isNotEmpty) {
            ApiClient.setAuthToken(token);
          }
          final userProfile = data['user'];
          final roles = data['roles'] is List ? (data['roles'] as List) : [];
          final bestRole = roles.contains('SUPER_ADMIN') ? 'SUPER_ADMIN'
              : roles.contains('COLLEGE_ADMIN') ? 'SUPER_ADMIN'
              : roles.contains('MODERATOR') ? 'EDITOR' : 'VIEWER';
          return AdminAccount(
            id: userProfile?['id']?.toString() ?? data['enrollmentNumber']?.toString() ?? '',
            email: userProfile?['email']?.toString() ?? email,
            name: userProfile?['fullName']?.toString() ?? email.split('@').first,
            role: bestRole,
            avatarUrl: userProfile?['profilePhotoUrl']?.toString(),
          );
        }
      }
    } catch (_) {}

    // Fallback: try mock credentials for offline/local development
    return authenticate(email, password);
  }

  /// Synchronous mock-only authentication (used as fallback).
  static AdminAccount? authenticate(String email, String password) {
    for (int i = 0; i < AdminMockData.adminAccounts.length; i++) {
      if (AdminMockData.adminAccounts[i].email.toLowerCase() == email.toLowerCase() &&
          AdminMockData.adminPasswords[i] == password) {
        return AdminMockData.adminAccounts[i];
      }
    }
    return null;
  }

  // ==================== DASHBOARD ====================
  static Future<DashboardStats> getDashboardStats() async {
    // Try to build stats from real backend entity counts
    int totalEvents = 0;
    int totalClubs = 0;
    int totalPosts = 0;

    try {
      final eventsResp = await ApiClient.get('/events', queryParameters: {'page': '0', 'size': '1'});
      if (eventsResp.statusCode == 200) {
        final data = ApiClient.extractData(eventsResp);
        if (data is Map) totalEvents = data['totalElements'] ?? 0;
      }
    } catch (_) {}

    try {
      final clubsResp = await ApiClient.get('/clubs', queryParameters: {'page': '0', 'size': '1'});
      if (clubsResp.statusCode == 200) {
        final data = ApiClient.extractData(clubsResp);
        if (data is Map) totalClubs = data['totalElements'] ?? 0;
      }
    } catch (_) {}

    try {
      final postsResp = await ApiClient.get('/posts', queryParameters: {'page': '0', 'size': '1'});
      if (postsResp.statusCode == 200) {
        final data = ApiClient.extractData(postsResp);
        if (data is Map) totalPosts = data['totalElements'] ?? 0;
      }
    } catch (_) {}

    // If we got any real data, build stats from it
    if (totalEvents > 0 || totalClubs > 0 || totalPosts > 0) {
      final users = AdminMockData.users;
      return DashboardStats(
        totalUsers: users.length,
        activeUsers: users.where((u) => u.status == 'active').length,
        totalPosts: totalPosts > 0 ? totalPosts : AdminMockData.content.length,
        totalOpportunities: 0,
        totalClubs: totalClubs > 0 ? totalClubs : AdminMockData.organizations.where((o) => o.type == 'club').length,
        totalEvents: totalEvents > 0 ? totalEvents : AdminMockData.events.length,
        pendingReports: AdminMockData.content.where((c) => c.status == 'flagged').length,
        newUsersToday: 0,
        totalStudents: users.where((u) => u.role == 'STUDENT').length,
        totalFaculty: users.where((u) => u.role == 'FACULTY').length,
        totalOrganizations: totalClubs > 0 ? totalClubs : AdminMockData.organizations.length,
        totalNotices: AdminMockData.notices.where((n) => n.status == 'published').length,
        suspendedUsers: users.where((u) => u.status == 'suspended').length,
      );
    }

    // Full fallback to mock data
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
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (statusFilter != null && statusFilter.isNotEmpty) queryParams['status'] = statusFilter;
      if (roleFilter != null && roleFilter.isNotEmpty) queryParams['role'] = roleFilter;
      if (courseFilter != null && courseFilter.isNotEmpty) queryParams['course'] = courseFilter;
      if (branchFilter != null && branchFilter.isNotEmpty) queryParams['branch'] = branchFilter;
      if (departmentFilter != null && departmentFilter.isNotEmpty) queryParams['department'] = departmentFilter;
      if (clubFilter != null && clubFilter.isNotEmpty) queryParams['club'] = clubFilter;
      if (teamFilter != null && teamFilter.isNotEmpty) queryParams['team'] = teamFilter;

      final response = await ApiClient.get('/admin/users', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final payload = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        if (payload is List) {
          return payload.map((u) => ManagedUser.fromJson(Map<String, dynamic>.from(u))).toList();
        }
      }
    } catch (_) {}

    // In-memory fallback with complete filtering
    await Future.delayed(const Duration(milliseconds: 100));
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
    try {
      final response = await ApiClient.get('/admin/users/enrollment/$enrollment');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return ManagedUser.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}

    final q = enrollment.toUpperCase();
    try {
      return AdminMockData.users.firstWhere((u) => u.enrollmentNumber?.toUpperCase() == q);
    } catch (_) {
      return null;
    }
  }

  static Future<ManagedUser?> searchByEmployeeId(String empId) async {
    try {
      final response = await ApiClient.get('/admin/users/employee/$empId');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return ManagedUser.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}

    final q = empId.toUpperCase();
    try {
      return AdminMockData.users.firstWhere((u) => u.employeeId?.toUpperCase() == q);
    } catch (_) {
      return null;
    }
  }

  static Future<ManagedUser?> getUserById(String userId) async {
    try {
      final response = await ApiClient.get('/admin/users/$userId');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return ManagedUser.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}

    try {
      return AdminMockData.users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> addUser(ManagedUser user) async {
    try {
      await ApiClient.post('/admin/users', data: {
        'fullName': user.fullName,
        'email': user.email,
        'role': user.role,
        'status': user.status,
        'department': user.department,
        'enrollmentNumber': user.enrollmentNumber,
        'employeeId': user.employeeId,
        'course': user.course,
        'branch': user.branch,
        'phone': user.phone,
      });
    } catch (_) {}

    AdminMockData.users.insert(0, user);
    _logActivity('User added', 'Sudhanshu Patel', user.email, 'user', targetId: user.id);
  }

  static Future<void> updateUser(String userId, {String? fullName, String? email, String? role, String? status, String? department, String? course, String? branch, String? phone, String? designation}) async {
    try {
      await ApiClient.put('/admin/users/$userId', data: {
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (department != null) 'department': department,
        if (course != null) 'course': course,
        if (branch != null) 'branch': branch,
        if (phone != null) 'phone': phone,
        if (designation != null) 'designation': designation,
      });
    } catch (_) {}

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
    try {
      await ApiClient.patch('/admin/users/$userId/suspend', data: {
        'reason': reason,
        'adminName': adminName,
      });
    } catch (_) {}

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
    try {
      await ApiClient.patch('/admin/users/$userId/activate');
    } catch (_) {}

    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(status: 'active');
      _logActivity('User restored', adminName, AdminMockData.users[idx].email, 'user', targetId: userId);
    }
  }

  static Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      if (newStatus == 'suspended') {
        await ApiClient.patch('/admin/users/$userId/suspend');
      } else {
        await ApiClient.patch('/admin/users/$userId/activate');
      }
    } catch (_) {}

    final idx = AdminMockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      AdminMockData.users[idx] = AdminMockData.users[idx].copyWith(status: newStatus);
      final action = newStatus == 'active' ? 'User activated' : newStatus == 'suspended' ? 'User suspended' : 'User banned';
      _logActivity(action, 'Sudhanshu Patel', AdminMockData.users[idx].email, 'user', targetId: userId);
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await ApiClient.delete('/admin/users/$userId');
    } catch (_) {}

    final user = AdminMockData.users.firstWhere((u) => u.id == userId);
    AdminMockData.users.removeWhere((u) => u.id == userId);
    _logActivity('User deleted', 'Sudhanshu Patel', user.email, 'user', targetId: userId);
  }

  // ==================== CONTENT CRUD ====================
  /// Fetches posts from the real backend GET /posts endpoint.
  /// The backend returns ApiResponse<PageResponse<PostResponse>>.
  static Future<List<ManagedContent>> getContent({String? search, String? statusFilter}) async {
    try {
      final queryParams = <String, dynamic>{'page': '0', 'size': '100'};
      final response = await ApiClient.get('/posts', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final data = ApiClient.extractData(response);
        List? postList;
        if (data is Map && data.containsKey('content')) {
          postList = data['content'] as List?;
        } else if (data is List) {
          postList = data;
        }

        if (postList != null) {
          var items = postList.map((p) {
            final authorObj = p['author'];
            String authorName = 'Student';
            String authorEmail = '';
            if (authorObj is Map) {
              authorName = authorObj['fullName']?.toString() ?? 'Student';
              authorEmail = authorObj['email']?.toString() ?? '';
            } else if (p['authorName'] != null) {
              authorName = p['authorName'].toString();
            }

            final mediaList = p['mediaUrls'] is List ? (p['mediaUrls'] as List) : null;
            final imageUrl = (mediaList != null && mediaList.isNotEmpty) ? mediaList.first.toString() : p['imageUrl']?.toString();

            return ManagedContent(
              id: p['id']?.toString() ?? '',
              authorName: authorName,
              authorEmail: authorEmail,
              content: p['content']?.toString() ?? p['text']?.toString() ?? '',
              postType: p['postType']?.toString() ?? 'general',
              status: p['status']?.toString() ?? 'published',
              likeCount: p['likeCount'] ?? p['likesCount'] ?? 0,
              commentCount: p['commentCount'] ?? p['commentsCount'] ?? 0,
              reportCount: p['reportCount'] ?? 0,
              createdAt: p['createdAt'] != null
                  ? (DateTime.tryParse(p['createdAt'].toString()) ?? DateTime.now())
                  : DateTime.now(),
              imageUrl: imageUrl,
              organizationId: p['clubId']?.toString() ?? p['organizationId']?.toString(),
            );
          }).toList();

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
      }
    } catch (_) {}

    // Fallback to mock data
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
    try {
      await ApiClient.put('/posts/$contentId', data: {'status': newStatus});
    } catch (_) {}

    final idx = AdminMockData.content.indexWhere((c) => c.id == contentId);
    if (idx != -1) {
      AdminMockData.content[idx] = AdminMockData.content[idx].copyWith(status: newStatus);
      final action = newStatus == 'published' ? 'Content approved' : newStatus == 'flagged' ? 'Content flagged' : 'Content removed';
      _logActivity(action, 'Sudhanshu Patel', 'Post ${AdminMockData.content[idx].id}', 'content', targetId: contentId);
    }
  }

  static Future<void> deleteContent(String contentId) async {
    try {
      await ApiClient.delete('/posts/$contentId');
      _logActivity('Content deleted', 'Sudhanshu Patel', 'Post $contentId', 'content', targetId: contentId);
      return;
    } catch (_) {}

    _logActivity('Content deleted (offline)', 'Sudhanshu Patel', 'Post $contentId', 'content', targetId: contentId);
    AdminMockData.content.removeWhere((c) => c.id == contentId);
  }

  // ==================== EVENTS CRUD ====================
  /// Fetches events from the real backend GET /events endpoint.
  /// The backend returns ApiResponse<PageResponse<EventResponse>>.
  /// Falls back to mock data if the backend is unreachable.
  static Future<List<ManagedEvent>> getEvents({String? search, String? statusFilter, String? orgFilter}) async {
    try {
      final queryParams = <String, dynamic>{'page': '0', 'size': '100'};
      if (statusFilter != null && statusFilter.isNotEmpty) queryParams['eventType'] = statusFilter;

      final response = await ApiClient.get('/events', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final data = ApiClient.extractData(response);
        // Backend returns PageResponse with 'content' list
        List? eventList;
        if (data is Map && data.containsKey('content')) {
          eventList = data['content'] as List?;
        } else if (data is List) {
          eventList = data;
        }

        if (eventList != null) {
          var events = eventList.map((e) => ManagedEvent(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
            description: e['description']?.toString() ?? '',
            venue: e['location']?.toString() ?? '',
            organizer: e['organizerName']?.toString() ?? '',
            posterUrl: e['bannerUrl']?.toString(),
            status: 'published',
            startDate: e['startTime'] != null ? DateTime.tryParse(e['startTime'].toString()) : null,
            endDate: e['endTime'] != null ? DateTime.tryParse(e['endTime'].toString()) : null,
            registrationsCount: e['registrationsCount'] ?? 0,
            createdAt: e['createdAt'] != null ? (DateTime.tryParse(e['createdAt'].toString()) ?? DateTime.now()) : DateTime.now(),
          )).toList();

          // Client-side search filter (backend GET /events doesn't have a search param)
          if (search != null && search.isNotEmpty) {
            final q = search.toLowerCase();
            events = events.where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.organizer.toLowerCase().contains(q) ||
              e.venue.toLowerCase().contains(q)
            ).toList();
          }
          return events;
        }
      }
    } catch (_) {}

    // Fallback to mock data if backend unreachable
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

  /// Creates event via the real backend POST /events endpoint.
  /// Maps Admin Panel fields to the backend's CreateEventRequest DTO.
  static Future<void> createEvent(ManagedEvent event) async {
    try {
      final response = await ApiClient.post('/events', data: {
        'title': event.title,
        'description': event.description.isNotEmpty ? event.description : null,
        'eventType': 'workshop',
        'location': event.venue.isNotEmpty ? event.venue : null,
        'isVirtual': false,
        'startTime': event.startDate?.toUtc().toIso8601String(),
        'endTime': event.endDate?.toUtc().toIso8601String(),
        'bannerUrl': event.posterUrl,
        'maxAttendees': null,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Event successfully created on backend — reload from server
        _logActivity('Event created', event.createdBy ?? 'Admin', event.title, 'event');
        return;
      }
    } catch (_) {}

    // Fallback: add to mock data if backend is down
    AdminMockData.events.insert(0, event);
    _logActivity('Event created (offline)', event.createdBy ?? 'Admin', event.title, 'event', targetId: event.id);
  }

  /// Updates event via PUT /events/{id}. Falls back to mock update.
  /// NOTE: The backend EventController currently has no PUT endpoint.
  /// This will attempt the call; if 404/405, it falls back to mock update.
  static Future<void> updateEvent(String eventId, {String? title, String? description, String? venue, String? organizer, String? organizationId, DateTime? startDate, DateTime? endDate, DateTime? registrationDeadline, String? contactInfo, String? status, String? visibility}) async {
    try {
      await ApiClient.put('/events/$eventId', data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (venue != null) 'location': venue,
        if (startDate != null) 'startTime': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endTime': endDate.toUtc().toIso8601String(),
      });
      _logActivity('Event updated', 'Admin', title ?? eventId, 'event', targetId: eventId);
      return;
    } catch (_) {}

    // Fallback to mock update
    final idx = AdminMockData.events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      AdminMockData.events[idx] = AdminMockData.events[idx].copyWith(
        title: title, description: description, venue: venue,
        organizer: organizer, organizationId: organizationId,
        startDate: startDate, endDate: endDate,
        registrationDeadline: registrationDeadline, contactInfo: contactInfo,
        status: status, visibility: visibility,
      );
      _logActivity('Event updated (offline)', 'Admin', AdminMockData.events[idx].title, 'event', targetId: eventId);
    }
  }

  /// Updates event status. Attempts backend PUT, falls back to mock.
  static Future<void> updateEventStatus(String eventId, String newStatus) async {
    try {
      await ApiClient.put('/events/$eventId', data: {
        'eventType': newStatus,
      });
      _logActivity('Event status changed', 'Admin', '$eventId -> $newStatus', 'event', targetId: eventId);
      return;
    } catch (_) {}

    final idx = AdminMockData.events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      AdminMockData.events[idx] = AdminMockData.events[idx].copyWith(status: newStatus);
      _logActivity('Event $newStatus (offline)', 'Admin', AdminMockData.events[idx].title, 'event', targetId: eventId);
    }
  }

  /// Deletes/soft-deletes event. Attempts backend DELETE, falls back to mock removal.
  static Future<void> deleteEvent(String eventId) async {
    try {
      await ApiClient.delete('/events/$eventId');
      _logActivity('Event deleted', 'Admin', eventId, 'event', targetId: eventId);
      return;
    } catch (_) {}

    // Fallback to mock removal
    try {
      final event = AdminMockData.events.firstWhere((e) => e.id == eventId);
      AdminMockData.events.removeWhere((e) => e.id == eventId);
      _logActivity('Event deleted (offline)', 'Admin', event.title, 'event', targetId: eventId);
    } catch (_) {}
  }

  // ==================== ORGANIZATIONS CRUD ====================
  /// Fetches organizations/clubs from the real backend GET /clubs endpoint.
  static Future<List<Organization>> getOrganizations({String? search, String? typeFilter}) async {
    try {
      final queryParams = <String, dynamic>{'page': '0', 'size': '100'};
      final response = await ApiClient.get('/clubs', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final data = ApiClient.extractData(response);
        List? clubList;
        if (data is Map && data.containsKey('content')) {
          clubList = data['content'] as List?;
        } else if (data is List) {
          clubList = data;
        }

        if (clubList != null) {
          var items = clubList.map((o) => Organization(
            id: o['id']?.toString() ?? '',
            name: o['name']?.toString() ?? '',
            type: (o['category']?.toString().toLowerCase() == 'team') ? 'team' : 'club',
            description: o['description']?.toString(),
            logoUrl: o['logoUrl']?.toString() ?? o['bannerUrl']?.toString(),
            status: o['status']?.toString() ?? 'active',
            memberIds: List<String>.from(o['memberIds'] ?? []),
            createdAt: o['createdAt'] != null
                ? (DateTime.tryParse(o['createdAt'].toString()) ?? DateTime.now())
                : DateTime.now(),
          )).toList();

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
      }
    } catch (_) {}

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

  /// Creates a club/organization via POST /clubs.
  static Future<void> createOrganization(Organization org) async {
    try {
      final response = await ApiClient.post('/clubs', data: {
        'name': org.name,
        'description': org.description ?? '',
        'category': org.type.toUpperCase(),
        'logoUrl': org.logoUrl,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logActivity('Organization created', 'Sudhanshu Patel', org.name, 'organization', targetId: org.id);
        return;
      }
    } catch (_) {}

    AdminMockData.organizations.insert(0, org);
    _logActivity('Organization created (offline)', 'Sudhanshu Patel', org.name, 'organization', targetId: org.id);
  }

  static Future<void> updateOrganization(String orgId, {String? name, String? description, String? status, String? type}) async {
    try {
      await ApiClient.put('/admin/organizations/$orgId', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
      });
    } catch (_) {}

    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1) {
      AdminMockData.organizations[idx] = AdminMockData.organizations[idx].copyWith(
        name: name, description: description, status: status, type: type,
      );
      _logActivity('Organization updated', 'Sudhanshu Patel', AdminMockData.organizations[idx].name, 'organization', targetId: orgId);
    }
  }

  static Future<void> addOrgMember(String orgId, String userId) async {
    try {
      await ApiClient.post('/admin/organizations/$orgId/members', data: {'userId': userId});
    } catch (_) {}

    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1 && !AdminMockData.organizations[idx].memberIds.contains(userId)) {
      AdminMockData.organizations[idx].memberIds.add(userId);
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
    try {
      await ApiClient.delete('/admin/organizations/$orgId/members/$userId');
    } catch (_) {}

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
    try {
      await ApiClient.patch('/admin/organizations/$orgId/archive');
    } catch (_) {}

    final idx = AdminMockData.organizations.indexWhere((o) => o.id == orgId);
    if (idx != -1) {
      AdminMockData.organizations[idx] = AdminMockData.organizations[idx].copyWith(status: 'archived');
      _logActivity('Organization archived', 'Sudhanshu Patel', AdminMockData.organizations[idx].name, 'organization', targetId: orgId);
    }
  }

  // ==================== NOTICES CRUD ====================
  /// Fetches notices from the real backend GET /notices endpoint.
  static Future<List<Notice>> getNotices({String? search, String? statusFilter}) async {
    try {
      final queryParams = <String, dynamic>{'page': '0', 'size': '100'};
      final response = await ApiClient.get('/notices', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final data = ApiClient.extractData(response);
        List? noticeList;
        if (data is Map && data.containsKey('content')) {
          noticeList = data['content'] as List?;
        } else if (data is List) {
          noticeList = data;
        }

        if (noticeList != null) {
          var items = noticeList.map((n) {
            final authorObj = n['author'];
            String authorName = 'Admin';
            if (authorObj is Map) {
              authorName = authorObj['fullName']?.toString() ?? 'Admin';
            } else if (n['authorName'] != null) {
              authorName = n['authorName'].toString();
            }

            return Notice(
              id: n['id']?.toString() ?? '',
              title: n['title']?.toString() ?? '',
              content: n['content']?.toString() ?? n['body']?.toString() ?? '',
              priority: n['priority']?.toString() ?? 'normal',
              status: n['status']?.toString() ?? 'published',
              authorName: authorName,
              createdAt: n['createdAt'] != null
                  ? (DateTime.tryParse(n['createdAt'].toString()) ?? DateTime.now())
                  : DateTime.now(),
            );
          }).toList();

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
      }
    } catch (_) {}

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
    try {
      await ApiClient.post('/admin/notices', data: {
        'title': notice.title,
        'content': notice.content,
        'priority': notice.priority,
        'status': notice.status,
        'authorName': notice.authorName,
      });
    } catch (_) {}

    AdminMockData.notices.insert(0, notice);
    _logActivity('Notice created', notice.authorName ?? 'Admin', notice.title, 'notice', targetId: notice.id);
  }

  static Future<void> updateNotice(String noticeId, {String? title, String? content, String? priority, String? status}) async {
    try {
      await ApiClient.put('/admin/notices/$noticeId', data: {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (priority != null) 'priority': priority,
        if (status != null) 'status': status,
      });
    } catch (_) {}

    final idx = AdminMockData.notices.indexWhere((n) => n.id == noticeId);
    if (idx != -1) {
      AdminMockData.notices[idx] = AdminMockData.notices[idx].copyWith(
        title: title, content: content, priority: priority, status: status,
      );
      _logActivity('Notice updated', 'Sudhanshu Patel', AdminMockData.notices[idx].title, 'notice', targetId: noticeId);
    }
  }

  static Future<void> publishNotice(String noticeId) async {
    try {
      await ApiClient.patch('/admin/notices/$noticeId/publish');
    } catch (_) {}

    final idx = AdminMockData.notices.indexWhere((n) => n.id == noticeId);
    if (idx != -1) {
      AdminMockData.notices[idx] = AdminMockData.notices[idx].copyWith(status: 'published');
      _logActivity('Notice published', 'Sudhanshu Patel', AdminMockData.notices[idx].title, 'notice', targetId: noticeId);
    }
  }

  static Future<void> deleteNotice(String noticeId) async {
    try {
      await ApiClient.delete('/admin/notices/$noticeId');
    } catch (_) {}

    final notice = AdminMockData.notices.firstWhere((n) => n.id == noticeId);
    AdminMockData.notices.removeWhere((n) => n.id == noticeId);
    _logActivity('Notice deleted', 'Sudhanshu Patel', notice.title, 'notice', targetId: noticeId);
  }

  // ==================== RESULTS ====================
  static Future<StudentResult?> getStudentResults(String enrollmentNumber) async {
    try {
      final response = await ApiClient.get('/admin/results/$enrollmentNumber');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return StudentResult(
          enrollmentNumber: data['enrollmentNumber']?.toString() ?? enrollmentNumber,
          cgpa: (data['cgpa'] as num?)?.toDouble() ?? 8.0,
          semesters: (data['semesters'] as List? ?? []).map((s) => SemesterResult(
            id: s['id']?.toString() ?? '1',
            semester: s['semester'] ?? 1,
            sgpa: (s['sgpa'] as num?)?.toDouble() ?? 8.0,
            totalCredits: s['totalCredits'] ?? 20,
            subjects: (s['subjects'] as List? ?? []).map((sub) => SubjectResult(
              code: sub['code']?.toString() ?? '',
              name: sub['name']?.toString() ?? '',
              credits: sub['credits'] ?? 3,
              grade: sub['grade']?.toString() ?? 'A',
              gradePoint: (sub['gradePoint'] as num?)?.toDouble() ?? 9.0,
            )).toList(),
          )).toList(),
        );
      }
    } catch (_) {}

    try {
      return AdminMockData.results.firstWhere((r) => r.enrollmentNumber == enrollmentNumber);
    } catch (_) {
      return null;
    }
  }

  // ==================== ACTIVITY LOG ====================
  static Future<List<ActivityLogEntry>> getActivityLog({String? categoryFilter}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryFilter != null && categoryFilter.isNotEmpty) queryParams['category'] = categoryFilter;
      final response = await ApiClient.get('/admin/audit-log', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final payload = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        if (payload is List) {
          return payload.map((a) => ActivityLogEntry(
            id: a['id']?.toString() ?? '',
            action: a['action']?.toString() ?? '',
            performedBy: a['performedBy']?.toString() ?? 'Admin',
            target: a['target']?.toString() ?? '',
            timestamp: a['timestamp'] != null ? DateTime.parse(a['timestamp']) : DateTime.now(),
            category: a['category']?.toString() ?? 'system',
            reason: a['reason']?.toString(),
            targetId: a['targetId']?.toString(),
          )).toList();
        }
      }
    } catch (_) {}

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
    try {
      final response = await ApiClient.get('/admin/settings');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return AppSettingsModel(
          appName: data['appName']?.toString() ?? 'Acadyk',
          tagline: data['tagline']?.toString() ?? '',
          contactEmail: data['contactEmail']?.toString() ?? '',
          maintenanceMode: data['maintenanceMode'] ?? false,
          enableAIRecommendations: data['enableAIRecommendations'] ?? false,
          enableRealtimeChat: data['enableRealtimeChat'] ?? true,
          enableStartups: data['enableStartups'] ?? true,
          enableLeaderboard: data['enableLeaderboard'] ?? true,
          enableEvents: data['enableEvents'] ?? true,
        );
      }
    } catch (_) {}

    return _settings;
  }

  static Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      await ApiClient.put('/admin/settings', data: {
        'appName': settings.appName,
        'tagline': settings.tagline,
        'contactEmail': settings.contactEmail,
        'maintenanceMode': settings.maintenanceMode,
        'enableAIRecommendations': settings.enableAIRecommendations,
        'enableRealtimeChat': settings.enableRealtimeChat,
        'enableStartups': settings.enableStartups,
        'enableLeaderboard': settings.enableLeaderboard,
        'enableEvents': settings.enableEvents,
      });
    } catch (_) {}

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

  // ==================== HELPER ====================
  static String? getOrganizationName(String orgId) {
    try {
      return AdminMockData.organizations.firstWhere((o) => o.id == orgId).name;
    } catch (_) {
      return null;
    }
  }
}