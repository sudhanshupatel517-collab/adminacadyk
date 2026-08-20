import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_responsive.dart';
import '../providers/admin_auth_provider.dart';
import '../../common/providers/theme_provider.dart';
import '../../app/theme/app_colors.dart';

class AdminNavItem {
  final String label;
  final String routeKey;
  final String section;

  const AdminNavItem({
    required this.label,
    required this.routeKey,
    this.section = 'MAIN',
  });
}

class AdminScaffold extends StatefulWidget {
  final String currentRoute;
  final Widget body;
  final Function(String) onNavigate;

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    required this.onNavigate,
  });

  static const List<AdminNavItem> navItems = [
    AdminNavItem(label: 'Dashboard', routeKey: 'dashboard', section: 'OVERVIEW'),
    AdminNavItem(label: 'Users', routeKey: 'users', section: 'MANAGEMENT'),
    AdminNavItem(label: 'Events', routeKey: 'events', section: 'MANAGEMENT'),
    AdminNavItem(label: 'Organizations', routeKey: 'organizations', section: 'MANAGEMENT'),
    AdminNavItem(label: 'Notices', routeKey: 'notices', section: 'COMMUNICATIONS'),
    AdminNavItem(label: 'Content', routeKey: 'content', section: 'COMMUNICATIONS'),
    AdminNavItem(label: 'Analytics', routeKey: 'analytics', section: 'SYSTEM'),
    AdminNavItem(label: 'Activity Log', routeKey: 'activity', section: 'SYSTEM'),
    AdminNavItem(label: 'Settings', routeKey: 'settings', section: 'SYSTEM'),
  ];

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AdminBreakpoints.isMobile(context);
    final isTablet = AdminBreakpoints.isTablet(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg(isDark),
      appBar: isMobile ? _buildMobileAppBar(isDark) : null,
      drawer: isMobile ? _buildProfileDrawer(isDark) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(isDark, isTablet),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) _buildDesktopTopBar(isDark),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(isDark) : null,
    );
  }

  // ─── Mobile App Bar ───
  PreferredSizeWidget _buildMobileAppBar(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;

    return AppBar(
      backgroundColor: AppColors.surfaceColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildAvatar(admin?.name, 16, isDark),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(22),
          const SizedBox(width: 8),
          Text(
            'Acadyk Admin',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.text(isDark),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        _buildThemeToggle(isDark),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border(isDark)),
      ),
    );
  }

  // ─── Mobile Drawer ───
  Widget _buildProfileDrawer(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;

    return Drawer(
      backgroundColor: AppColors.surfaceColor(isDark),
      width: 272,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  _buildAvatar(admin?.name, 20, isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          admin?.name ?? 'Administrator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text(isDark),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatRole(admin?.role),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMut(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border(isDark)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: AdminScaffold.navItems.map((item) {
                  final isActive = widget.currentRoute == item.routeKey;
                  return _buildDrawerItem(isDark, item, isActive, () {
                    Navigator.pop(context);
                    widget.onNavigate(item.routeKey);
                  });
                }).toList(),
              ),
            ),
            Container(height: 1, color: AppColors.border(isDark)),
            _buildSignOutRow(isDark, () {
              Navigator.pop(context);
              _handleLogout();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(bool isDark, AdminNavItem item, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.surfaceAlt(isDark) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isActive ? Border(left: BorderSide(color: AppColors.text(isDark), width: 3)) : null,
            ),
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.text(isDark) : AppColors.textSec(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Desktop Sidebar ───
  Widget _buildSidebar(bool isDark, bool isCompact) {
    final width = isCompact ? 100.0 : 220.0;

    // Group nav items by section
    final Map<String, List<AdminNavItem>> sections = {};
    for (var item in AdminScaffold.navItems) {
      sections.putIfAbsent(item.section, () => []).add(item);
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        border: Border(right: BorderSide(color: AppColors.border(isDark), width: 1)),
      ),
      child: Column(
        children: [
          // Brand header
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _buildLogo(22),
                const SizedBox(width: 10),
                Text(
                  'Acadyk',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.3,
                    color: AppColors.text(isDark),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMut(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.border(isDark)),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: [
                for (var entry in sections.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 5),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMut(isDark),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...entry.value.map((item) {
                    final isActive = widget.currentRoute == item.routeKey;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _buildFullNavItem(item, isActive, isDark),
                    );
                  }),
                ],
              ],
            ),
          ),

          // Sign out
          Container(height: 1, color: AppColors.border(isDark)),
          _buildSignOutRow(isDark, _handleLogout),
        ],
      ),
    );
  }

  Widget _buildFullNavItem(AdminNavItem item, bool isActive, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => widget.onNavigate(item.routeKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surfaceAlt(isDark) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.text(isDark) : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.text(isDark) : AppColors.textSec(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Desktop Top Bar ───
  Widget _buildDesktopTopBar(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        border: Border(bottom: BorderSide(color: AppColors.border(isDark), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Page title + breadcrumb
          Text(
            _routeToTitle(widget.currentRoute),
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 14,
            color: AppColors.border(isDark),
          ),
          const SizedBox(width: 10),
          Text(
            _routeToSubtitle(widget.currentRoute),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textMut(isDark),
            ),
          ),

          const Spacer(),

          // Theme toggle text button
          _buildThemeToggle(isDark),
          const SizedBox(width: 12),

          // Profile
          GestureDetector(
            onTap: () => _showProfileMenu(isDark, admin),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt(isDark),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border(isDark), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatar(admin?.name, 11, isDark),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin?.name ?? 'Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(isDark),
                        ),
                      ),
                      Text(
                        _formatRole(admin?.role),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMut(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Theme Toggle (Text-First) ───
  Widget _buildThemeToggle(bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: _toggleTheme,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt(isDark),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border(isDark), width: 1),
        ),
        child: Text(
          isDark ? 'Light Mode' : 'Dark Mode',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSec(isDark),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Nav (Mobile) ───
  Widget _buildBottomNav(bool isDark) {
    final bottomItems = [
      AdminScaffold.navItems[0], // Dashboard
      AdminScaffold.navItems[1], // Users
      AdminScaffold.navItems[2], // Events
      AdminScaffold.navItems[4], // Notices
      AdminScaffold.navItems[8], // Settings
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        border: Border(top: BorderSide(color: AppColors.border(isDark), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(bottomItems.length, (index) {
              final item = bottomItems[index];
              final isActive = item.routeKey == widget.currentRoute;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onNavigate(item.routeKey),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.surfaceAlt(isDark) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AppColors.text(isDark) : AppColors.textMut(isDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─── Shared Helpers ───

  Widget _buildLogo(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/images/lagacy.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? name, double radius, bool isDark) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceAlt(isDark),
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : 'A',
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
          color: AppColors.text(isDark),
        ),
      ),
    );
  }

  Widget _buildSignOutRow(bool isDark, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMut(isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatRole(String? role) {
    if (role == null || role.isEmpty) return 'Viewer';
    return role.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    themeProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _showProfileMenu(bool isDark, dynamic admin) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 52, 24, 0),
      color: AppColors.surfaceColor(isDark),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: AppColors.border(isDark), width: 1),
      ),
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem<dynamic>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin?.name ?? 'Administrator',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.text(isDark)),
              ),
              Text(
                admin?.email ?? '',
                style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark)),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<dynamic>(
          onTap: () => widget.onNavigate('settings'),
          child: Text('Settings', style: TextStyle(fontSize: 13, color: AppColors.textSec(isDark))),
        ),
        PopupMenuItem<dynamic>(
          onTap: _handleLogout,
          child: Text('Sign Out', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFF87171) : AppColors.error)),
        ),
      ],
    );
  }

  String _routeToTitle(String route) {
    switch (route) {
      case 'dashboard': return 'Dashboard';
      case 'users': return 'User Management';
      case 'events': return 'Event Management';
      case 'organizations': return 'Clubs & Teams';
      case 'notices': return 'Notices';
      case 'content': return 'Content Moderation';
      case 'analytics': return 'Analytics';
      case 'activity': return 'Activity Log';
      case 'settings': return 'Settings';
      default: return 'Dashboard';
    }
  }

  String _routeToSubtitle(String route) {
    switch (route) {
      case 'dashboard': return 'System overview & statistics';
      case 'users': return 'Accounts & enrollments';
      case 'events': return 'Campus schedules & registration';
      case 'organizations': return 'Societies & departments';
      case 'notices': return 'Institutional circulars';
      case 'content': return 'Student posts & reports';
      case 'analytics': return 'Platform metrics';
      case 'activity': return 'Audit trail';
      case 'settings': return 'Preferences';
      default: return '';
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: AppColors.border(isDark), width: 1),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.text(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          content: Text(
            'Are you sure you want to end your administrative session?',
            style: TextStyle(
              color: AppColors.textSec(isDark),
              fontSize: 12.5,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border(isDark)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AdminAuthProvider>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.brand,
                foregroundColor: isDark ? AppColors.brand : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
          ],
        );
      },
    );
  }
}