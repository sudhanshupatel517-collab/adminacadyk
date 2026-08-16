import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

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

  Future<void> toggleUserStatus(String userId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    await AdminService.updateUserStatus(userId, newStatus);
    await loadUsers();
  }
}