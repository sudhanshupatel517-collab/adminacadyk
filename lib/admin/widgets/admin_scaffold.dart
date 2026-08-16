import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_responsive.dart';
import '../providers/admin_auth_provider.dart';
import '../../common/providers/theme_provider.dart';

class AdminNavItem {
  final String label;
  final IconData icon;
  final String routeKey;

  const AdminNavItem({
    required this.label,
    required this.icon,
    required this.routeKey,
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
    AdminNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, routeKey: 'dashboard'),
    AdminNavItem(label: 'User Directory', icon: Icons.people_outline_rounded, routeKey: 'users'),
    AdminNavItem(label: 'Content Moderation', icon: Icons.shield_outlined, routeKey: 'content'),
    AdminNavItem(label: 'Analytics & Reports', icon: Icons.insights_rounded, routeKey: 'analytics'),
    AdminNavItem(label: 'Audit Log', icon: Icons.history_rounded, routeKey: 'activity'),
    AdminNavItem(label: 'System Settings', icon: Icons.tune_rounded, routeKey: 'settings'),
  ];

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getPageTitle() {
    switch (widget.currentRoute) {
      case 'dashboard':
        return 'System Overview';
      case 'users':
        return 'User Management';
      case 'content':
        return 'Content Moderation Queue';
      case 'analytics':
        return 'Analytics & Institutional Metrics';
      case 'activity':
        return 'System Audit Log';
      case 'settings':
        return 'System Configuration';
      default:
        return 'Admin Console';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AdminBreakpoints.isMobile(context);
    final isTablet = AdminBreakpoints.isTablet(context);

    final sidebarBg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB);
    final contentBg = isDark ? const Color(0xFF090D13) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: contentBg,
      appBar: isMobile ? _buildMobileAppBar(isDark, borderColor) : null,
      drawer: isMobile ? _buildProfileDrawer(isDark, borderColor) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(isDark, isTablet, sidebarBg, borderColor),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) _buildDesktopTopBar(isDark, borderColor),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(isDark, borderColor) : null,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(bool isDark, Color borderColor) {
    final admin = context.watch<AdminAuthProvider>().currentAdmin;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: borderColor, height: 1),
      ),
      leading: IconButton(
        icon: CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF0A66C2),
          child: Text(
            admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/lagacy.png',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, size: 20, color: Color(0xFF0A66C2)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getPageTitle(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 18,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF4B5563),
          ),
          onPressed: () {
            final tp = context.read<ThemeProvider>();
            tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
        ),
      ],
    );
  }

  Widget _buildProfileDrawer(bool isDark, Color borderColor) {
    final auth = context.read<AdminAuthProvider>();
    final admin = auth.currentAdmin;
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF0A66C2),
                    child: Text(
                      admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin?.name ?? 'Administrator', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                        Text(admin?.email ?? 'admin@acadyk.edu', style: TextStyle(fontSize: 12, color: textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A66C2).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            admin?.role ?? 'SUPER_ADMIN',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0A66C2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: borderColor, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.tune_rounded, size: 18),
                    title: const Text('System Settings', style: TextStyle(fontSize: 13)),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('settings');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded, size: 18),
                    title: const Text('Audit Log', style: TextStyle(fontSize: 13)),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('activity');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18),
                    title: Text(isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode', style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      final tp = context.read<ThemeProvider>();
                      tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                  ),
                ],
              ),
            ),
            Divider(color: borderColor, height: 1),
            ListTile(
              dense: true,
              leading: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
              title: const Text('Sign Out', style: TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                auth.logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark, bool isTablet, Color bg, Color borderColor) {
    final auth = context.watch<AdminAuthProvider>();
    final admin = auth.currentAdmin;
    final width = isTablet ? 64.0 : 240.0;
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Organization Header
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: isTablet
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset('assets/images/lagacy.png', width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Color(0xFF0A66C2))),
                    ),
                  )
                : Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset('assets/images/lagacy.png', width: 22, height: 22, errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Color(0xFF0A66C2))),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Acadyk Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.2)),
                          Text('Campus Administration', style: TextStyle(fontSize: 11, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              children: AdminScaffold.navItems.map((item) {
                final isActive = widget.currentRoute == item.routeKey;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: InkWell(
                    onTap: () => widget.onNavigate(item.routeKey),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 38,
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isActive && !isTablet
                            ? Border(left: BorderSide(color: const Color(0xFF0A66C2), width: 3))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: isTablet ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Icon(
                            item.icon,
                            size: 17,
                            color: isActive
                                ? (isDark ? Colors.white : const Color(0xFF0A66C2))
                                : textSecondary,
                          ),
                          if (!isTablet) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                  color: isActive ? textPrimary : textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom User Profile & Sign Out
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: isTablet
                ? IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
                    tooltip: 'Sign Out',
                    onPressed: () => auth.logout(),
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF0A66C2),
                        child: Text(
                          admin?.name.isNotEmpty == true ? admin!.name[0].toUpperCase() : 'A',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              admin?.name ?? 'Admin',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                            ),
                            Text(
                              admin?.role ?? 'SUPER_ADMIN',
                              style: TextStyle(fontSize: 10, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout_rounded, size: 16, color: textSecondary),
                        tooltip: 'Sign Out',
                        onPressed: () => auth.logout(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar(bool isDark, Color borderColor) {
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Acadyk', style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 16, color: textSecondary),
              const SizedBox(width: 6),
              Text(
                _getPageTitle(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
              ),
            ],
          ),
          Row(
            children: [
              // Theme Toggle Button
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 18,
                  color: textSecondary,
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  final tp = context.read<ThemeProvider>();
                  tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
              const SizedBox(width: 8),
              // Status Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Operational', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, Color borderColor) {
    final bottomNavItems = [
      AdminScaffold.navItems[0], // Dashboard
      AdminScaffold.navItems[1], // Users
      AdminScaffold.navItems[2], // Content
      AdminScaffold.navItems[3], // Analytics
      AdminScaffold.navItems[4], // Activity
    ];

    int currentIndex = bottomNavItems.indexWhere((item) => item.routeKey == widget.currentRoute);
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => widget.onNavigate(bottomNavItems[i].routeKey),
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 58,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: bottomNavItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon, size: 18),
            label: item.label.split(' ')[0], // Compact label for mobile
          );
        }).toList(),
      ),
    );
  }
}