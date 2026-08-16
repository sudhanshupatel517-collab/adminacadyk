import 'package:flutter/material.dart';

class RouteGuards {
  static String? checkAuthRedirect(BuildContext context, String currentPath) {
    // Dedicated Admin Panel router: root and admin routes pass directly to AdminRootScreen
    if (currentPath == '/' || currentPath.startsWith('/admin')) {
      return null;
    }
    return '/admin';
  }
}