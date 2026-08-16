import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

enum ContentLoadState { initial, loading, loaded, error }

class AdminContentProvider extends ChangeNotifier {
  List<ManagedContent> _content = [];
  ContentLoadState _state = ContentLoadState.initial;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;

  List<ManagedContent> get content => _content;
  bool get isLoading => _state == ContentLoadState.loading;
  Future<bool> updateContentStatus(String id, String status) => updateStatus(id, status);
  ContentLoadState get state => _state;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;

  Future<void> loadContent() async {
    _state = ContentLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _content = await AdminService.getContent(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _statusFilter,
      );
      _state = ContentLoadState.loaded;
      notifyListeners();
    } catch (e) {
      _state = ContentLoadState.error;
      _error = 'Failed to load content: $e';
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadContent();
  }

  void setStatusFilter(String? status) {
    _statusFilter = (status == null || status.isEmpty || status == 'all') ? null : status;
    loadContent();
  }

  Future<bool> updateStatus(String contentId, String newStatus) async {
    try {
      await AdminService.updateContentStatus(contentId, newStatus);
      await loadContent();
      return true;
    } catch (e) {
      _error = 'Failed to update content: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContent(String contentId) async {
    try {
      await AdminService.deleteContent(contentId);
      await loadContent();
      return true;
    } catch (e) {
      _error = 'Failed to delete content: $e';
      notifyListeners();
      return false;
    }
  }
}