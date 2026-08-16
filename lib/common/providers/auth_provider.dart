import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthUser? _currentUser;
  ProfileModel? _currentProfile;
  bool _isLoading = false;

  AuthProvider() {
    try {
      _currentUser = AuthService.currentUser;
      if (_currentUser != null) {
        _fetchProfile(_currentUser!.id);
      }
    } catch (e) {
      debugPrint('AuthProvider initialization error: $e');
    }
  }

  AuthUser? get currentUser => _currentUser;
  ProfileModel? get currentProfile => _currentProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void bypassSignIn() {
    final mockUser = AuthUser(
      id: 'mock-dev-user-id-999',
      email: 'developer@acadyk.com',
      fullName: 'Somraj Lodhi',
      roles: ['STUDENT'],
    );

    final mockProfile = ProfileModel.fromJson({
      'id': 'mock-dev-user-id-999',
      'email': 'developer@acadyk.com',
      'full_name': 'Somraj Lodhi',
      'username': 'somraj-dev',
    });

    _currentUser = mockUser;
    _currentProfile = mockProfile;
    notifyListeners();
  }

  Future<void> _fetchProfile(String userId) async {
    final profileData = await ProfileService.getProfile(userId);
    if (profileData != null) {
      _currentProfile = ProfileModel.fromJson(profileData);
    } else {
      final mockProfile = ProfileModel.fromJson({
        'id': userId,
        'email': _currentUser?.email ?? 'developer@acadyk.com',
        'full_name': _currentUser?.fullName ?? 'Somraj Lodhi',
        'username': 'somraj-dev',
      });
      _currentProfile = mockProfile;
    }
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_currentUser != null) {
      await _fetchProfile(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    try {
      final user = await AuthService.signUpWithEmail(
        email,
        password,
        fullName: fullName,
      );
      if (user != null) {
        _currentUser = user;
        await _fetchProfile(user.id);
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final user = await AuthService.signInWithEmail(email, password);
      if (user != null) {
        _currentUser = user;
        await _fetchProfile(user.id);
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        await _fetchProfile(user.id);
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await AuthService.sendPasswordReset(email);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await AuthService.signOut();
      _currentUser = null;
      _currentProfile = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await AuthService.deleteAccount();
      _currentUser = null;
      _currentProfile = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
