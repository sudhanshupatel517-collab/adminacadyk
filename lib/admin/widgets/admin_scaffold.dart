import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_responsive.dart';
import '../providers/admin_auth_provider.dart';
import '../../common/providers/theme_provider.dart';

class AdminNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String routeKey;

  const AdminNavItem({required this.label, required this.icon, required this.activeIcon, required this.routeKey});
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
    AdminNavItem(label: 'Dashboard', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, routeKey: 'dashboard'),
    AdminNavItem(label: 'Users', icon: Icons.people_alt_outlined, activeIcon: Icons.people_alt_rounded, routeKey: 'users'),
    AdminNavItem(label: 'Events', icon: Icons.event_outlined, activeIcon: Icons.event_rounded, routeKey: 'events'),
    AdminNavItem(label: 'Organizations', icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded, routeKey: 'organizations'),
    AdminNavItem(label: 'Notices', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, routeKey: 'notices'),
    AdminNavItem(label: 'Content', icon: Icons.description_outlined, activeIcon: Icons.description_rounded, routeKey: 'content'),
    AdminNavItem(label: 'Analytics', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, routeKey: 'analytics'),
    AdminNavItem(label: 'Activity', icon: Icons.schedule_outlined, activeIcon: Icons.schedule_rounded, routeKey: 'activity'),
    AdminNavItem(label: 'Settings', icon: Icons.tune_outlined, activeIcon: Icons.tune_rounded, routeKey: 'settings'),
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

    final sidebarBg = isDark ? const Color(0xFF0C0C0C) : const Color(0xFFFFFFFF);
    final contentBg = isDark ? const Color(0xFF111111) : const Color(0xFFF7F7F8);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: contentBg,
      appBar: isMobile ? _buildMobileAppBar(isDark) : null,
      drawer: isMobile ? _buildProfileDrawer(isDark) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(isDark, isTablet, sidebarBg),
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

  PreferredSizeWidget _buildMobileAppBar(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0C0C0C) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
            child: Text(
              admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
      title: _buildLogo(28),
      centerTitle: true,
      actions: [
        _buildThemeToggle(isDark),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE)),
      ),
    );
  }

  Widget _buildProfileDrawer(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0C0C0C) : Colors.white,
      width: 300,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                    child: Text(
                      admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
                      style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(admin?.name ?? 'Admin', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  )),
                  const SizedBox(height: 4),
                  Text(admin?.email ?? '', style: TextStyle(
                    fontSize: 13, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
                  )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      admin?.role ?? 'VIEWER',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: borderColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _buildDrawerItem(isDark, Icons.groups_rounded, 'Organizations', () {
                    Navigator.pop(context);
                    widget.onNavigate('organizations');
                  }),
                  _buildDrawerItem(isDark, Icons.campaign_rounded, 'Notices', () {
                    Navigator.pop(context);
                    widget.onNavigate('notices');
                  }),
                  _buildDrawerItem(isDark, Icons.tune_rounded, 'Settings', () {
                    Navigator.pop(context);
                    widget.onNavigate('settings');
                  }),
                  _buildDrawerItem(isDark, Icons.security_rounded, 'Security', () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(isDark, Icons.help_outline_rounded, 'Help & Support', () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
            Container(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _handleLogout(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 20, color: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828)),
                        const SizedBox(width: 12),
                        Text('Sign Out', style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(bool isDark, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                )),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark, bool isCompact, Color bgColor) {
    final width = isCompact ? 68.0 : 260.0;
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8E8E8);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 22),
            alignment: isCompact ? Alignment.center : Alignment.centerLeft,
            child: Row(
              mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
              children: [
                _buildLogo(isCompact ? 26 : 28),
                if (!isCompact) ...[
                  const SizedBox(width: 10),
                  Text('Acadyk', style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  )),
                ],
              ],
            ),
          ),
          Container(height: 1, color: borderColor),
          if (!isCompact)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('MENU', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
                  letterSpacing: 1.2,
                )),
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12, vertical: 4),
              children: AdminScaffold.navItems.map((item) {
                final isActive = widget.currentRoute == item.routeKey;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: isCompact
                      ? _buildCompactNavItem(item, isActive, isDark)
                      : _buildFullNavItem(item, isActive, isDark),
                );
              }).toList(),
            ),
          ),
          Container(height: 1, color: borderColor),
          Padding(
            padding: EdgeInsets.all(isCompact ? 8 : 12),
            child: isCompact
                ? Tooltip(
                    message: 'Sign Out',
                    child: IconButton(
                      icon: Icon(Icons.logout_rounded, size: 20, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
                      onPressed: () => _handleLogout(),
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _handleLogout(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 18, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
                            const SizedBox(width: 12),
                            Text('Sign Out', style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullNavItem(AdminNavItem item, bool isActive, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => widget.onNavigate(item.routeKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon, size: 20,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                    : (isDark ? const Color(0xFF707070) : const Color(0xFF888888)),
              ),
              const SizedBox(width: 12),
              Text(item.label, style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                    : (isDark ? const Color(0xFF999999) : const Color(0xFF666666)),
              )),
              if (isActive) ...[
                const Spacer(),
                Container(width: 4, height: 4, decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A), shape: BoxShape.circle,
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNavItem(AdminNavItem item, bool isActive, bool isDark) {
    return Tooltip(
      message: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onNavigate(item.routeKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(
              isActive ? item.activeIcon : item.icon, size: 22,
              color: isActive
                  ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                  : (isDark ? const Color(0xFF707070) : const Color(0xFF888888)),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8E8E8);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Text(_routeToTitle(widget.currentRoute), style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          )),
          const SizedBox(width: 12),
          Text(_routeToSubtitle(widget.currentRoute), style: TextStyle(
            fontSize: 13, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
          )),
          const Spacer(),
          _buildThemeToggle(isDark),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showProfileMenu(isDark, admin),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                    child: Text(
                      admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(admin?.name ?? 'Admin', style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      )),
                      Text(admin?.role ?? 'VIEWER', style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                      )),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.expand_more_rounded, size: 18, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 18, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
        ),
        onPressed: () => _toggleTheme(),
        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final bottomItems = [
      AdminScaffold.navItems[0], // Dashboard
      AdminScaffold.navItems[1], // Users
      AdminScaffold.navItems[2], // Events
      AdminScaffold.navItems[5], // Content
      AdminScaffold.navItems[7], // Activity
    ];


    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8E8E8), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon, size: 22,
                          color: isActive
                              ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                              : (isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA)),
                        ),
                        const SizedBox(height: 4),
                        Text(item.label, style: TextStyle(
                          fontSize: 10, letterSpacing: 0.2,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                              : (isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA)),
                        )),
                      ],
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

  Widget _buildLogo(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/lagacy.png',
        width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size, height: size,
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(size * 0.22)),
          child: Center(child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.45))),
        ),
      ),
    );
  }

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    themeProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _showProfileMenu(bool isDark, dynamic admin) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 64, 28, 0),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem<dynamic>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(admin?.name ?? 'Admin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              Text(admin?.email ?? '', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF999999))),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<dynamic>(
          onTap: () => widget.onNavigate('settings'),
          child: Row(children: [
            Icon(Icons.tune_rounded, size: 18, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555)),
            const SizedBox(width: 10),
            Text('Settings', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555))),
          ]),
        ),
        PopupMenuItem<dynamic>(
          onTap: () => _handleLogout(),
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18, color: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828)),
            const SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828))),
          ]),
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
      case 'notices': return 'Notices & Announcements';
      case 'content': return 'Content Moderation';
      case 'analytics': return 'Analytics';
      case 'activity': return 'Activity Log';
      case 'settings': return 'Settings';
      default: return 'Dashboard';
    }
  }

  String _routeToSubtitle(String route) {
    switch (route) {
      case 'dashboard': return 'Overview & insights';
      case 'users': return 'Manage platform users, students & faculty';
      case 'events': return 'Create, publish & schedule campus events';
      case 'organizations': return 'Manage clubs, teams & memberships';
      case 'notices': return 'Publish institutional announcements';
      case 'content': return 'Review & moderate posts';
      case 'analytics': return 'Growth & engagement data';
      case 'activity': return 'Audit trail & administrative history';
      case 'settings': return 'Platform configuration';
      default: return '';
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Sign Out', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 18)),
          content: Text('You will be returned to the login screen.', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666), fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF999999) : const Color(0xFF666666))),
            ),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); context.read<AdminAuthProvider>().logout(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }
}