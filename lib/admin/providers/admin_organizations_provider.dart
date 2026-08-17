import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

class AdminOrganizationsProvider extends ChangeNotifier {
  List<Organization> _organizations = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _typeFilter;

  List<Organization> get organizations => _organizations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrganizations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _organizations = await AdminService.getOrganizations(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        typeFilter: _typeFilter,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load organizations: $e';
      notifyListeners();
    }
  }

  void setSearch(String query) { _searchQuery = query; loadOrganizations(); }
  void setTypeFilter(String? type) { _typeFilter = (type == null || type.isEmpty) ? null : type; loadOrganizations(); }

  Future<bool> createOrganization({required String name, required String type, String? description, String? department}) async {
    try {
      final org = Organization(
        id: AdminMockData.nextOrgId(),
        name: name,
        type: type,
        description: description,
        department: department,
        createdAt: DateTime.now(),
      );
      await AdminService.createOrganization(org);
      await loadOrganizations();
      return true;
    } catch (e) {
      _error = 'Failed to create organization: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrganization(String orgId, {String? name, String? description, String? status}) async {
    try {
      await AdminService.updateOrganization(orgId, name: name, description: description, status: status);
      await loadOrganizations();
      return true;
    } catch (e) {
      _error = 'Failed to update organization: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMember(String orgId, String userId) async {
    try {
      await AdminService.addOrgMember(orgId, userId);
      await loadOrganizations();
      return true;
    } catch (e) {
      _error = 'Failed to add member: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMember(String orgId, String userId) async {
    try {
      await AdminService.removeOrgMember(orgId, userId);
      await loadOrganizations();
      return true;
    } catch (e) {
      _error = 'Failed to remove member: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveOrganization(String orgId) async {
    try {
      await AdminService.archiveOrganization(orgId);
      await loadOrganizations();
      return true;
    } catch (e) {
      _error = 'Failed to archive organization: $e';
      notifyListeners();
      return false;
    }
  }
}
