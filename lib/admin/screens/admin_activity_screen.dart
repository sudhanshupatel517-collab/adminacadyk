import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  List<ActivityLogEntry> _logs = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    final items = await AdminService.getActivityLog(categoryFilter: _categoryFilter);
    if (mounted) {
      setState(() {
        _logs = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);

    var filtered = _logs;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
        e.action.toLowerCase().contains(q) ||
        e.performedBy.toLowerCase().contains(q) ||
        e.target.toLowerCase().contains(q)
      ).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Audit Log',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Immutable audit trail of administrator and system actions',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 40,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    decoration: InputDecoration(
                      hintText: 'Search audit events...',
                      hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA)),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButton<String>(
                      value: _categoryFilter ?? 'all',
                      dropdownColor: cardBg,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Categories')),
                        DropdownMenuItem(value: 'user', child: Text('User Management')),
                        DropdownMenuItem(value: 'content', child: Text('Content Moderation')),
                        DropdownMenuItem(value: 'settings', child: Text('System Settings')),
                      ],
                      onChanged: (val) {
                        _categoryFilter = (val == null || val == 'all') ? null : val;
                        _loadLogs();
                      },
                    ),
                  ),
                ),
                Text('${filtered.length} audit records', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF888888) : const Color(0xFF666666))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Log List
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (ctx, i) => Divider(color: borderColor, height: 1),
                itemBuilder: (ctx, index) {
                  final entry = filtered[index];
                  IconData icon;
                  Color iconColor;

                  switch (entry.category) {
                    case 'user':
                      icon = Icons.person_rounded;
                      iconColor = const Color(0xFF1565C0);
                      break;
                    case 'content':
                      icon = Icons.description_rounded;
                      iconColor = const Color(0xFF7B1FA2);
                      break;
                    case 'settings':
                      icon = Icons.settings_rounded;
                      iconColor = const Color(0xFFF59E0B);
                      break;
                    default:
                      icon = Icons.shield_rounded;
                      iconColor = const Color(0xFF00BA7C);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 16, color: iconColor),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.action,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entry.performedBy} -> ${entry.target}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTime(entry.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF666666) : const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}