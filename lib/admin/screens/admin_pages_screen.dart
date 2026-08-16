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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSearchBar(
            hint: 'Search pages & routes...',
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 20),
          AdminDataView<Map<String, dynamic>>(
            items: filtered,
            columns: const ['Page Title', 'Route', 'Category', 'Visibility', 'Status'],
            rowBuilder: (p) => [
              p['title'],
              p['route'],
              p['type'],
              p['visibility'],
              p['status'],
            ],
            mobileCardBuilder: (p) {
              final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p['title'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BA7C).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(p['status'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF00BA7C))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(p['route'], style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black45, fontFamily: 'monospace')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(p['type'], style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                        ),
                        const SizedBox(width: 8),
                        Text(p['visibility'], style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
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