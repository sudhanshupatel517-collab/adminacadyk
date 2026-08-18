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
  final String section;

  const AdminNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
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
    AdminNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, routeKey: 'dashboard', section: 'OVERVIEW'),
    AdminNavItem(label: 'Users', icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, routeKey: 'users', section: 'MANAGEMENT'),
    AdminNavItem(label: 'Events', icon: Icons.event_outlined, activeIcon: Icons.event_rounded, routeKey: 'events', section: 'MANAGEMENT'),
    AdminNavItem(label: 'Organizations', icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded, routeKey: 'organizations', section: 'MANAGEMENT'),
    AdminNavItem(label: 'Notices', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, routeKey: 'notices', section: 'COMMUNICATIONS'),
    AdminNavItem(label: 'Content', icon: Icons.article_outlined, activeIcon: Icons.article_rounded, routeKey: 'content', section: 'COMMUNICATIONS'),
    AdminNavItem(label: 'Analytics', icon: Icons.insights_outlined, activeIcon: Icons.insights_rounded, routeKey: 'analytics', section: 'SYSTEM'),
    AdminNavItem(label: 'Activity Log', icon: Icons.history_rounded, activeIcon: Icons.history_rounded, routeKey: 'activity', section: 'SYSTEM'),
    AdminNavItem(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, routeKey: 'settings', section: 'SYSTEM'),
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

    final sidebarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final contentBg = isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);

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
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            child: Text(
              admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(24),
          const SizedBox(width: 8),
          Text(
            'Acadyk Admin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
        child: Container(height: 1, color: borderColor),
      ),
    );
  }

  Widget _buildProfileDrawer(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      width: 280,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    child: Text(
                      admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          admin?.role ?? 'SUPER_ADMIN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: borderColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                children: AdminScaffold.navItems.map((item) {
                  final isActive = widget.currentRoute == item.routeKey;
                  return _buildDrawerItem(isDark, item, isActive, () {
                    Navigator.pop(context);
                    widget.onNavigate(item.routeKey);
                  });
                }).toList(),
              ),
            ),
            Container(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                        const SizedBox(width: 12),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                          ),
                        ),
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

  Widget _buildDrawerItem(bool isDark, AdminNavItem item, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 18,
                  color: isActive
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark, bool isCompact, Color bgColor) {
    final width = isCompact ? 68.0 : 240.0;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    // Group nav items by section
    final Map<String, List<AdminNavItem>> sections = {};
    for (var item in AdminScaffold.navItems) {
      sections.putIfAbsent(item.section, () => []).add(item);
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          // Sidebar Brand Header
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 18),
            alignment: isCompact ? Alignment.center : Alignment.centerLeft,
            child: Row(
              mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
              children: [
                _buildLogo(isCompact ? 24 : 26),
                if (!isCompact) ...[
                  const SizedBox(width: 10),
                  Text(
                    'Acadyk',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(height: 1, color: borderColor),

          // Nav Items List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: 12),
              children: [
                for (var entry in sections.entries) ...[
                  if (!isCompact)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ...entry.value.map((item) {
                    final isActive = widget.currentRoute == item.routeKey;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: isCompact
                          ? _buildCompactNavItem(item, isActive, isDark)
                          : _buildFullNavItem(item, isActive, isDark),
                    );
                  }),
                ],
              ],
            ),
          ),

          // Sidebar Footer / Sign out
          Container(height: 1, color: borderColor),
          Padding(
            padding: EdgeInsets.all(isCompact ? 8 : 10),
            child: isCompact
                ? Tooltip(
                    message: 'Sign Out',
                    child: IconButton(
                      icon: Icon(Icons.logout_rounded, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      onPressed: () => _handleLogout(),
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _handleLogout(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            const SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
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
        borderRadius: BorderRadius.circular(6),
        onTap: () => widget.onNavigate(item.routeKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 18,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                  ),
                ),
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
          borderRadius: BorderRadius.circular(6),
          onTap: () => widget.onNavigate(item.routeKey),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                size: 19,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(bool isDark) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Page Title & Subtitle Breadcrumb
          Text(
            _routeToTitle(widget.currentRoute),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '/',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _routeToSubtitle(widget.currentRoute),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),

          const Spacer(),

          // Theme Mode Toggle
          _buildThemeToggle(isDark),
          const SizedBox(width: 12),

          // Administrator Profile Badge
          GestureDetector(
            onTap: () => _showProfileMenu(isDark, admin),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    child: Text(
                      admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
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
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        admin?.role ?? 'VIEWER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: IconButton(
        icon: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 16,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
        onPressed: () => _toggleTheme(),
        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final bottomItems = [
      AdminScaffold.navItems[0], // Dashboard
      AdminScaffold.navItems[1], // Users
      AdminScaffold.navItems[2], // Events
      AdminScaffold.navItems[4], // Notices
      AdminScaffold.navItems[8], // Settings
    ];
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 54,
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
                          isActive ? item.activeIcon : item.icon,
                          size: 20,
                          color: isActive
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          ),
                        ),
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
            color: const Color(0xFF0F172A),
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

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    themeProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _showProfileMenu(bool isDark, dynamic admin) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 56, 24, 0),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1),
      ),
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem<dynamic>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin?.name ?? 'Administrator',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                admin?.email ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<dynamic>(
          onTap: () => widget.onNavigate('settings'),
          child: Row(children: [
            Icon(Icons.tune_rounded, size: 16, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            const SizedBox(width: 10),
            Text('Settings', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
          ]),
        ),
        PopupMenuItem<dynamic>(
          onTap: () => _handleLogout(),
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 16, color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
            const SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))),
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
        final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: 1),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          content: Text(
            'Are you sure you want to end your administrative session?',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AdminAuthProvider>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              ),
              child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }
}