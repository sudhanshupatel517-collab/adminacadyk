class FirebaseAuthService {
  static Future<void> init() async {}

  static Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    return {
      'id': 'u-1',
      'email': email,
      'fullName': 'Admin User',
      'roles': ['ADMIN', 'SUPER_ADMIN'],
    };
  }

  static Future<Map<String, dynamic>> signUpWithEmail(String email, String password, {String? fullName}) async {
    return {
      'id': 'u-new',
      'email': email,
      'fullName': fullName ?? 'New User',
      'roles': ['STUDENT'],
    };
  }

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    return {
      'id': 'u-google',
      'email': 'google.user@acadyk.edu',
      'fullName': 'Google User',
      'roles': ['STUDENT'],
    };
  }

  static Future<void> sendPasswordReset(String email) async {}
  static Future<void> sendEmailVerification() async {}
  static Future<void> signOut() async {}
  static Future<void> deleteAccount() async {}
}
