import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

enum UserLoadState { initial, loading, loaded, error }

class AdminUsersProvider extends ChangeNotifier {
  List<ManagedUser> _users = [];
  UserLoadState _state = UserLoadState.initial;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _roleFilter;

  List<ManagedUser> get users => _users;
  UserLoadState get state => _state;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get roleFilter => _roleFilter;

  Future<void> loadUsers() async {
    _state = UserLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _users = await AdminService.getUsers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _statusFilter,
        roleFilter: _roleFilter,
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

  Future<bool> addUser({
    required String fullName,
    required String email,
    required String role,
    String? department,
  }) async {
    try {
      final newUser = ManagedUser(
        id: AdminMockData.nextUserId(),
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        status: 'active',
        department: (department != null && department.trim().isNotEmpty) ? department.trim() : null,
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