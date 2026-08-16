import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../data/admin_models.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_responsive.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  List<ActivityLogEntry> _allEntries = [];
  bool _isLoading = true;
  String _categoryFilter = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await AdminService.getActivityLog();
    if (mounted) {
      setState(() {
        _allEntries = logs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF13171F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    final filtered = _allEntries.where((e) {
      if (_categoryFilter.isNotEmpty && e.category != _categoryFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e.action.toLowerCase().contains(q) ||
            e.performedBy.toLowerCase().contains(q) ||
            e.target.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Toolbar
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              if (isMobile) {
                return Column(
                  children: [
                    AdminSearchBar(
                      hint: 'Search audit log by actor, action or target...',
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryDropdown(isDark),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AdminSearchBar(
                      hint: 'Search system audit log by actor, action, or target...',
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryDropdown(isDark),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Audit Log Table
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: AdminEmptyState(
                          icon: Icons.history_rounded,
                          title: 'No audit logs found',
                          subtitle: 'Try adjusting your category filter or search query.',
                        ),
                      )
                    : Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2.0),
                          2: FlexColumnWidth(2.0),
                          3: FlexColumnWidth(2.0),
                          4: FlexColumnWidth(1.5),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF9FAFB),
                              border: Border(bottom: BorderSide(color: borderColor)),
                            ),
                            children: [
                              _buildTableHeader('EVENT ID', isDark),
                              _buildTableHeader('ACTION', isDark),
                              _buildTableHeader('PERFORMED BY', isDark),
                              _buildTableHeader('TARGET RESOURCE', isDark),
                              _buildTableHeader('TIMESTAMP', isDark, alignRight: true),
                            ],
                          ),
                          ...filtered.map((e) {
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: borderColor.withOpacity(0.6))),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(e.id, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: textSecondary)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: _getCategoryColor(e.category)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(e.action, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(e.performedBy, style: TextStyle(fontSize: 12, color: textPrimary)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(e.target, style: TextStyle(fontSize: 12, color: textSecondary)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(
                                    _formatTimestamp(e.timestamp),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 11, color: textSecondary),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFD1D5DB);
    final bg = isDark ? const Color(0xFF13171F) : Colors.white;
    final text = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoryFilter,
          style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w500),
          dropdownColor: bg,
          icon: Icon(Icons.arrow_drop_down_rounded, size: 18, color: text),
          onChanged: (v) => setState(() => _categoryFilter = v ?? ''),
          items: const [
            DropdownMenuItem(value: '', child: Text('All Events')),
            DropdownMenuItem(value: 'user', child: Text('User Management')),
            DropdownMenuItem(value: 'content', child: Text('Content Moderation')),
            DropdownMenuItem(value: 'settings', child: Text('System Settings')),
            DropdownMenuItem(value: 'system', child: Text('System Actions')),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, bool isDark, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280)),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'user':
        return const Color(0xFF0A66C2);
      case 'content':
        return const Color(0xFFDC2626);
      case 'settings':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF059669);
    }
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';
  }
}