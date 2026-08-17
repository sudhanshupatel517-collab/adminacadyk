import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../common/services/auth_service.dart';
import '../core/network/websocket_service.dart';
import '../common/providers/auth_provider.dart';
import '../common/providers/profile_provider.dart';
import '../common/providers/theme_provider.dart';
import '../admin/providers/admin_auth_provider.dart';
import '../admin/providers/admin_dashboard_provider.dart';
import '../admin/providers/admin_users_provider.dart';
import '../admin/providers/admin_content_provider.dart';
import '../admin/providers/admin_settings_provider.dart';
import '../admin/providers/admin_events_provider.dart';
import '../admin/providers/admin_organizations_provider.dart';
import '../admin/providers/admin_notices_provider.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AuthService.init();
    WebSocketService.connect();
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }

  runApp(
    ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ProfileProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
          // Admin Providers
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminContentProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminSettingsProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminEventsProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminOrganizationsProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminNoticesProvider()),
        ],
        child: const AcadykApp(),
      ),
    ),
  );
}