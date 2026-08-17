import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

class AdminNoticesProvider extends ChangeNotifier {
  List<Notice> _notices = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;

  List<Notice> get notices => _notices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notices = await AdminService.getNotices(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _statusFilter,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load notices: $e';
      notifyListeners();
    }
  }

  void setSearch(String query) { _searchQuery = query; loadNotices(); }
  void setStatusFilter(String? status) { _statusFilter = (status == null || status.isEmpty) ? null : status; loadNotices(); }

  Future<bool> createNotice({required String title, required String content, String priority = 'normal', String? authorName}) async {
    try {
      final notice = Notice(
        id: 'notice-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        priority: priority,
        status: 'draft',
        authorName: authorName,
        createdAt: DateTime.now(),
      );
      await AdminService.createNotice(notice);
      await loadNotices();
      return true;
    } catch (e) {
      _error = 'Failed to create notice: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNotice(String noticeId, {String? title, String? content, String? priority, String? status}) async {
    try {
      await AdminService.updateNotice(noticeId, title: title, content: content, priority: priority, status: status);
      await loadNotices();
      return true;
    } catch (e) {
      _error = 'Failed to update notice: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishNotice(String noticeId) async {
    try {
      await AdminService.publishNotice(noticeId);
      await loadNotices();
      return true;
    } catch (e) {
      _error = 'Failed to publish notice: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotice(String noticeId) async {
    try {
      await AdminService.deleteNotice(noticeId);
      await loadNotices();
      return true;
    } catch (e) {
      _error = 'Failed to delete notice: $e';
      notifyListeners();
      return false;
    }
  }
}
