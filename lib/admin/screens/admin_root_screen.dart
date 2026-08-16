import 'package:flutter/material.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_content_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_settings_screen.dart';

class AdminRootScreen extends StatefulWidget {
  final String initialTab;
  const AdminRootScreen({super.key, this.initialTab = 'dashboard'});

  @override
  State<AdminRootScreen> createState() => _AdminRootScreenState();
}

class _AdminRootScreenState extends State<AdminRootScreen> {
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: _currentRoute,
      onNavigate: (route) {
        setState(() {
          _currentRoute = route;
        });
      },
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case 'dashboard':
        return const AdminDashboardScreen();
      case 'users':
        return const AdminUsersScreen();
      case 'content':
        return const AdminContentScreen();
      case 'analytics':
        return const AdminAnalyticsScreen();
      case 'activity':
        return const AdminActivityScreen();
      case 'settings':
        return const AdminSettingsScreen();
      default:
        return const AdminDashboardScreen();
    }
  }
}