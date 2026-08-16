import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

enum LoadState { initial, loading, loaded, error }

class AdminDashboardProvider extends ChangeNotifier {
  DashboardStats? _stats;
  List<ActivityLogEntry> _recentActivity = [];
  LoadState _state = LoadState.initial;
  String? _error;

  DashboardStats? get stats => _stats;
  List<ActivityLogEntry> get recentActivity => _recentActivity;
  LoadState get state => _state;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _stats = await AdminService.getDashboardStats();
      final allLogs = await AdminService.getActivityLog();
      _recentActivity = allLogs.take(5).toList();
      _state = LoadState.loaded;
      notifyListeners();
    } catch (e) {
      _state = LoadState.error;
      _error = 'Failed to load dashboard: $e';
      notifyListeners();
    }
  }
}