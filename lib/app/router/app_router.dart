import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../admin/screens/admin_root_screen.dart';
import 'route_names.dart';
import 'route_guards.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.admin,
  redirect: (context, state) {
    return RouteGuards.checkAuthRedirect(context, state.uri.path);
  },
  routes: [
    GoRoute(
      path: RouteNames.initial,
      builder: (context, state) => const AdminRootScreen(initialTab: 'dashboard'),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AdminRootScreen(initialTab: 'dashboard'),
    ),
    GoRoute(
      path: RouteNames.admin,
      builder: (context, state) => const AdminRootScreen(initialTab: 'dashboard'),
    ),
    GoRoute(
      path: RouteNames.adminDashboard,
      builder: (context, state) => const AdminRootScreen(initialTab: 'dashboard'),
    ),
    GoRoute(
      path: RouteNames.adminUsers,
      builder: (context, state) => const AdminRootScreen(initialTab: 'users'),
    ),
    GoRoute(
      path: RouteNames.adminContent,
      builder: (context, state) => const AdminRootScreen(initialTab: 'content'),
    ),
    GoRoute(
      path: RouteNames.adminAnalytics,
      builder: (context, state) => const AdminRootScreen(initialTab: 'analytics'),
    ),
    GoRoute(
      path: RouteNames.adminActivity,
      builder: (context, state) => const AdminRootScreen(initialTab: 'activity'),
    ),
    GoRoute(
      path: RouteNames.adminSettings,
      builder: (context, state) => const AdminRootScreen(initialTab: 'settings'),
    ),
  ],
);