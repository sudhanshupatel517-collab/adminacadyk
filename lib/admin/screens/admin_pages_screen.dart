import 'package:flutter/material.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminPagesScreen extends StatefulWidget {
  const AdminPagesScreen({super.key});

  @override
  State<AdminPagesScreen> createState() => _AdminPagesScreenState();
}

class _AdminPagesScreenState extends State<AdminPagesScreen> {
  final List<Map<String, dynamic>> _pages = [
    {'title': 'Home Feed', 'route': '/home', 'status': 'active', 'type': 'Core', 'visibility': 'Public'},
    {'title': 'Discover Opportunities', 'route': '/opportunities', 'status': 'active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Student Clubs', 'route': '/clubs', 'status': 'active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Campus Events', 'route': '/events', 'status': 'active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Startup Showcase', 'route': '/startups', 'status': 'active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Leaderboard', 'route': '/leaderboard', 'status': 'active', 'type': 'Gamification', 'visibility': 'Public'},
    {'title': 'User Profile', 'route': '/profile', 'status': 'active', 'type': 'User', 'visibility': 'Authenticated'},
    {'title': 'Direct Messages', 'route': '/messages', 'status': 'active', 'type': 'Communication', 'visibility': 'Authenticated'},
    {'title': 'Notifications', 'route': '/notifications', 'status': 'active', 'type': 'System', 'visibility': 'Authenticated'},
    {'title': 'Admin Console', 'route': '/admin', 'status': 'active', 'type': 'Management', 'visibility': 'Admin Only'},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _pages.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['route'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Platform Routes & Navigation Pages',
            padding: EdgeInsets.only(bottom: 16),
          ),
          AdminSearchBar(
            hint: 'Search platform routes & pages...',
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 18),
          AdminDataTable(
            columns: const [
              AdminDataTableColumn(label: 'PAGE TITLE', flex: 3),
              AdminDataTableColumn(label: 'ROUTE', flex: 3),
              AdminDataTableColumn(label: 'CATEGORY', flex: 2),
              AdminDataTableColumn(label: 'VISIBILITY', flex: 2),
              AdminDataTableColumn(label: 'STATUS', flex: 2),
            ],
            itemCount: filtered.length,
            itemBuilder: (ctx, index) {
              final p = filtered[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        p['title'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        p['route'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMut(isDark),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        p['type'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSec(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        p['visibility'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMut(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AdminStatusBadge(status: p['status']),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}