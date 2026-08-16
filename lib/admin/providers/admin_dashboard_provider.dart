import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

enum LoadState { idle, loading, loaded, error }

class AdminDashboardProvider extends ChangeNotifier {
  DashboardStats? _stats;
  List<ActivityLogEntry> _recentActivity = [];
  LoadState _state = LoadState.idle;
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
      final results = await Future.wait([
        AdminService.getDashboardStats(),
        AdminService.getActivityLog(),
      ]);
      _stats = results[0] as DashboardStats;
      _recentActivity = (results[1] as List<ActivityLogEntry>).take(6).toList();
      _state = LoadState.loaded;
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}