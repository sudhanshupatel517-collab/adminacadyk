import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/feed/presentation/screens/home_feed_screen.dart';
import '../../features/feed/presentation/screens/discover_opportunities_screen.dart';
import '../../features/feed/presentation/screens/clubs_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/appearance_screen.dart';
import '../../features/profile/presentation/screens/settings_account_management_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/chat/presentation/screens/message_center_screen.dart';
import '../../admin/screens/admin_root_screen.dart';
import 'route_names.dart';
import 'route_guards.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.initial,
  redirect: (context, state) {
    return RouteGuards.checkAuthRedirect(context, state.uri.path);
  },
  routes: [
    GoRoute(
      path: RouteNames.initial,
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.appearance,
      builder: (context, state) => const AppearanceScreen(),
    ),
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: RouteNames.messages,
      builder: (context, state) => const MessageCenterScreen(),
    ),
    GoRoute(
      path: RouteNames.opportunities,
      builder: (context, state) => const DiscoverOpportunitiesScreen(),
    ),
    GoRoute(
      path: RouteNames.clubs,
      builder: (context, state) => const ClubsScreen(),
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsAccountManagementScreen(),
    ),

    // â”€â”€ Admin Native Routes â”€â”€
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