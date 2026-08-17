import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

enum UserLoadState { initial, loading, loaded, error }

class AdminUsersProvider extends ChangeNotifier {
  List<ManagedUser> _users = [];
  UserLoadState _state = UserLoadState.initial;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _roleFilter;
  String? _courseFilter;
  String? _branchFilter;
  String? _departmentFilter;
  String? _clubFilter;
  String? _teamFilter;

  // Selected user for detail view
  ManagedUser? _selectedUser;
  StudentResult? _selectedUserResults;

  List<ManagedUser> get users => _users;
  bool get isLoading => _state == UserLoadState.loading;
  UserLoadState get state => _state;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get roleFilter => _roleFilter;
  String? get courseFilter => _courseFilter;
  String? get branchFilter => _branchFilter;
  String? get departmentFilter => _departmentFilter;
  String? get clubFilter => _clubFilter;
  String? get teamFilter => _teamFilter;
  ManagedUser? get selectedUser => _selectedUser;
  StudentResult? get selectedUserResults => _selectedUserResults;

  bool get hasActiveFilters =>
    _courseFilter != null || _branchFilter != null ||
    _departmentFilter != null || _clubFilter != null || _teamFilter != null;

  Future<void> loadUsers() async {
    _state = UserLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _users = await AdminService.getUsers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _statusFilter,
        roleFilter: _roleFilter,
        courseFilter: _courseFilter,
        branchFilter: _branchFilter,
        departmentFilter: _departmentFilter,
        clubFilter: _clubFilter,
        teamFilter: _teamFilter,
      );
      _state = UserLoadState.loaded;
      notifyListeners();
    } catch (e) {
      _state = UserLoadState.error;
      _error = 'Failed to load users: $e';
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadUsers();
  }

  void setStatusFilter(String? status) {
    _statusFilter = (status == null || status.isEmpty || status == 'all') ? null : status;
    loadUsers();
  }

  void setRoleFilter(String? role) {
    _roleFilter = (role == null || role.isEmpty || role == 'all') ? null : role;
    loadUsers();
  }

  void setCourseFilter(String? course) {
    _courseFilter = (course == null || course.isEmpty) ? null : course;
    loadUsers();
  }

  void setBranchFilter(String? branch) {
    _branchFilter = (branch == null || branch.isEmpty) ? null : branch;
    loadUsers();
  }

  void setDepartmentFilter(String? dept) {
    _departmentFilter = (dept == null || dept.isEmpty) ? null : dept;
    loadUsers();
  }

  void setClubFilter(String? clubId) {
    _clubFilter = (clubId == null || clubId.isEmpty) ? null : clubId;
    loadUsers();
  }

  void setTeamFilter(String? teamId) {
    _teamFilter = (teamId == null || teamId.isEmpty) ? null : teamId;
    loadUsers();
  }

  void clearAllFilters() {
    _courseFilter = null;
    _branchFilter = null;
    _departmentFilter = null;
    _clubFilter = null;
    _teamFilter = null;
    _statusFilter = null;
    _roleFilter = null;
    loadUsers();
  }

  Future<void> selectUser(String userId) async {
    _selectedUser = await AdminService.getUserById(userId);
    if (_selectedUser?.enrollmentNumber != null) {
      _selectedUserResults = await AdminService.getStudentResults(_selectedUser!.enrollmentNumber!);
    } else {
      _selectedUserResults = null;
    }
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
    _selectedUserResults = null;
    notifyListeners();
  }

  Future<bool> addUser({
    required String fullName,
    required String email,
    required String role,
    String? department,
    String? enrollmentNumber,
    String? employeeId,
    String? course,
    String? branch,
    String? phone,
    String? designation,
  }) async {
    try {
      final newUser = ManagedUser(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        status: 'active',
        department: (department != null && department.trim().isNotEmpty) ? department.trim() : null,
        enrollmentNumber: enrollmentNumber?.trim(),
        employeeId: employeeId?.trim(),
        course: course,
        branch: branch,
        phone: phone?.trim(),
        designation: designation?.trim(),
        joinedAt: DateTime.now(),
        lastActive: DateTime.now(),
        postsCount: 0,
      );
      await AdminService.addUser(newUser);
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Failed to add user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(String userId, {
    required String fullName,
    required String email,
    required String role,
    required String status,
    String? department,
  }) async {
    try {
      await AdminService.updateUser(
        userId,
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        status: status,
        department: (department != null && department.trim().isNotEmpty) ? department.trim() : null,
      );
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Failed to update user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> suspendUser(String userId, String reason, String adminName) async {
    try {
      await AdminService.suspendUser(userId, reason, adminName);
      await loadUsers();
      // Refresh selected user if viewing
      if (_selectedUser?.id == userId) {
        await selectUser(userId);
      }
      return true;
    } catch (e) {
      _error = 'Failed to suspend user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreUser(String userId, String adminName) async {
    try {
      await AdminService.restoreUser(userId, adminName);
      await loadUsers();
      if (_selectedUser?.id == userId) {
        await selectUser(userId);
      }
      return true;
    } catch (e) {
      _error = 'Failed to restore user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(String userId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
      await AdminService.updateUserStatus(userId, newStatus);
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Failed to update status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await AdminService.deleteUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Failed to delete user: $e';
      notifyListeners();
      return false;
    }
  }
}