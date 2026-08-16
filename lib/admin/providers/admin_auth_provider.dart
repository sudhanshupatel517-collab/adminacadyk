import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

class AdminAuthProvider extends ChangeNotifier {
  AdminAccount? _currentAdmin = AdminMockData.adminAccounts[0]; // Bypass login by default
  bool _isLoading = false;
  String? _errorMessage;

  AdminAccount? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuperAdmin => _currentAdmin?.isSuperAdmin ?? false;
  bool get isEditor => _currentAdmin?.isEditor ?? false;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final account = AdminService.authenticate(email, password);
      if (account != null) {
        _currentAdmin = account;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentAdmin = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}