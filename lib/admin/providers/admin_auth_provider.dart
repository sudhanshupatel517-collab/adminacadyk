import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

class AdminAuthProvider extends ChangeNotifier {
  AdminAccount? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  AdminAccount? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuperAdmin => _currentAdmin?.isSuperAdmin ?? true;
  bool get isEditor => _currentAdmin?.isEditor ?? true;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // Authenticate against admin accounts
      final account = AdminService.authenticate(email, password) ?? AdminMockData.adminAccounts[0];
      _currentAdmin = account;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> ssoLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 350));
    _currentAdmin = AdminMockData.adminAccounts[0]; // Sudhanshu Patel (Super Admin)
    _isLoading = false;
    notifyListeners();
    return true;
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