import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_mock_data.dart';

class AdminAuthProvider extends ChangeNotifier {
  AdminAccount? _currentAdmin = AdminMockData.adminAccounts[0];

  AdminAccount? get currentAdmin => _currentAdmin ?? AdminMockData.adminAccounts[0];
  bool get isAuthenticated => true;
  bool get isLoading => false;
  String? get errorMessage => null;
  bool get isSuperAdmin => true;
  bool get isEditor => true;

  Future<bool> login(String email, String password) async {
    _currentAdmin = AdminMockData.adminAccounts[0];
    notifyListeners();
    return true;
  }

  void logout() {
    // Kept for UI callback
    notifyListeners();
  }

  void clearError() {}
}