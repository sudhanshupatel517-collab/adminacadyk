import 'package:flutter/material.dart';
import '../../common/services/auth_service.dart';

class RouteGuards {
  static bool isAuthenticated() {
    return AuthService.isAuthenticated;
  }

  static String? checkAuthRedirect(BuildContext context, String currentPath) {
    // Admin routes handle their own authentication in AdminRootScreen
    if (currentPath.startsWith('/admin')) {
      return null;
    }

    final bool loggedIn = isAuthenticated();
    final bool isAuthRoute = currentPath == '/login';

    if (!loggedIn && !isAuthRoute) {
      return '/login';
    }
    if (loggedIn && isAuthRoute) {
      return '/home';
    }
    return null;
  }
}