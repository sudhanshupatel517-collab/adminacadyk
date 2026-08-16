import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

class AdminContentProvider extends ChangeNotifier {
  List<ManagedContent> _content = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = '';

  List<ManagedContent> get content => _content;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _content = await AdminService.getContent(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        statusFilter: _statusFilter.isNotEmpty ? _statusFilter : null,
      );
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load content: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadContent();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    loadContent();
  }

  Future<void> updateContentStatus(String id, String newStatus) async {
    await AdminService.updateContentStatus(id, newStatus);
    await loadContent();
  }
}