import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

class AdminUsersProvider extends ChangeNotifier {
  List<ManagedUser> _users = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = '';
  String _roleFilter = '';

  List<ManagedUser> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get roleFilter => _roleFilter;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await AdminService.getUsers(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        statusFilter: _statusFilter.isNotEmpty ? _statusFilter : null,
        roleFilter: _roleFilter.isNotEmpty ? _roleFilter : null,
      );
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load users: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadUsers();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    loadUsers();
  }

  void setRoleFilter(String filter) {
    _roleFilter = filter;
    loadUsers();
  }

  Future<bool> addUser({
    required String fullName,
    required String email,
    required String role,
    required String department,
    String status = 'active',
  }) async {
    try {
      final newUser = ManagedUser(
        id: AdminMockData.nextUserId(),
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        department: department.trim(),
        status: status,
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

  Future<bool> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
    required String department,
    required String status,
  }) async {
    try {
      await AdminService.updateUser(
        id,
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        department: department.trim(),
        status: status,
      );
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Failed to update user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleUserStatus(String userId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    await AdminService.updateUserStatus(userId, newStatus);
    await loadUsers();
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