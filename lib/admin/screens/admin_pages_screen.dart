import 'package:flutter/material.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_data_table.dart';

class AdminPagesScreen extends StatefulWidget {
  const AdminPagesScreen({super.key});

  @override
  State<AdminPagesScreen> createState() => _AdminPagesScreenState();
}

class _AdminPagesScreenState extends State<AdminPagesScreen> {
  final List<Map<String, dynamic>> _pages = [
    {'title': 'Home Feed', 'route': '/home', 'status': 'Active', 'type': 'Core', 'visibility': 'Public'},
    {'title': 'Discover Opportunities', 'route': '/opportunities', 'status': 'Active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Student Clubs', 'route': '/clubs', 'status': 'Active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Campus Events', 'route': '/events', 'status': 'Active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Startup Showcase', 'route': '/startups', 'status': 'Active', 'type': 'Feature', 'visibility': 'Public'},
    {'title': 'Leaderboard', 'route': '/leaderboard', 'status': 'Active', 'type': 'Gamification', 'visibility': 'Public'},
    {'title': 'User Profile', 'route': '/profile', 'status': 'Active', 'type': 'User', 'visibility': 'Authenticated'},
    {'title': 'Direct Messages', 'route': '/messages', 'status': 'Active', 'type': 'Communication', 'visibility': 'Authenticated'},
    {'title': 'Notifications', 'route': '/notifications', 'status': 'Active', 'type': 'System', 'visibility': 'Authenticated'},
    {'title': 'Admin Console', 'route': '/admin', 'status': 'Active', 'type': 'Management', 'visibility': 'Admin Only'},
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
          AdminSearchBar(
            hint: 'Search platform routes & pages...',
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 18),
          AdminDataView<Map<String, dynamic>>(
            items: filtered,
            columns: const ['PAGE TITLE', 'ROUTE', 'CATEGORY', 'VISIBILITY', 'STATUS'],
            rowBuilder: (p) => [
              p['title'],
              p['route'],
              p['type'],
              p['visibility'],
              p['status'],
            ],
            mobileCardBuilder: (p) {
              final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p['title'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFBBF7D0)),
                          ),
                          child: Text(p['status'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(p['route'], style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontFamily: 'monospace')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(p['type'], style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                        ),
                        const SizedBox(width: 8),
                        Text(p['visibility'], style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                      ],
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