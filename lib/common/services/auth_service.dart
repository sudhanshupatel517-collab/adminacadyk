import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/auth/firebase_auth_service.dart';

class AuthUser {
  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final List<String> roles;

  AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.roles = const ['STUDENT'],
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] is List
        ? (json['roles'] as List).map((e) => e.toString()).toList()
        : ['STUDENT'];
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'],
      username: json['username']?.toString(),
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'username': username,
      'roles': roles,
    };
  }
}

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static AuthUser? _currentUser;

  static AuthUser? get currentUser => _currentUser;
  static bool get isAuthenticated => _currentUser != null;

  static Future<void> init() async {
    await FirebaseAuthService.init();
    final userJson = await _storage.read(key: 'user_profile');
    if (userJson != null) {
      try {
        _currentUser = AuthUser.fromJson(jsonDecode(userJson));
      } catch (_) {}
    }
  }

  static Future<AuthUser?> signInWithEmail(String email, String password) async {
    final data = await FirebaseAuthService.signInWithEmail(email, password);
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    _currentUser = AuthUser.fromJson(userMap);
    await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
    return _currentUser;
  }

  static Future<AuthUser?> signUpWithEmail(String email, String password, {String? fullName}) async {
    final data = await FirebaseAuthService.signUpWithEmail(email, password, fullName: fullName);
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    _currentUser = AuthUser.fromJson(userMap);
    await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
    return _currentUser;
  }

  static Future<AuthUser?> signInWithGoogle() async {
    final data = await FirebaseAuthService.signInWithGoogle();
    if (data == null) return null;
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    _currentUser = AuthUser.fromJson(userMap);
    await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
    return _currentUser;
  }

  static Future<void> sendPasswordReset(String email) async {
    await FirebaseAuthService.sendPasswordReset(email);
  }

  static Future<void> sendEmailVerification() async {
    await FirebaseAuthService.sendEmailVerification();
  }

  static Future<void> signOut() async {
    await FirebaseAuthService.signOut();
    _currentUser = null;
  }

  static Future<void> deleteAccount() async {
    await FirebaseAuthService.deleteAccount();
    _currentUser = null;
  }
}
