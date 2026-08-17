import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

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
      // Try real backend authentication first, then mock fallback
      final account = await AdminService.authenticateAsync(email, password);
      if (account != null) {
        _currentAdmin = account;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
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

  Future<bool> ssoLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 350));
    // Default SSO admin account — replace with real Firebase SSO integration
    _currentAdmin = AdminAccount(
      id: 'admin-sso',
      email: 'admin@acadyk.edu',
      name: 'Sudhanshu Patel',
      role: 'SUPER_ADMIN',
    );
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