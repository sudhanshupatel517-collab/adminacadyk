import 'package:flutter/material.dart';
import 'admin_responsive.dart';

/// Responsive data display: Table on desktop, Cards on mobile
class AdminDataView<T> extends StatelessWidget {
  final List<T> items;
  final List<String> columns;
  final List<String> Function(T item) rowBuilder;
  final Widget Function(T item)? mobileCardBuilder;
  final void Function(T item)? onTap;
  final bool isLoading;
  final String? emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AdminDataView({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    this.mobileCardBuilder,
    this.onTap,
    this.isLoading = false,
    this.emptyMessage,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
      ));
    }
    if (errorMessage != null) {
      return _buildErrorState(context);
    }
    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    final isMobile = AdminBreakpoints.isMobile(context);
    if (isMobile && mobileCardBuilder != null) {
      return _buildMobileCards(context);
    }
    return _buildDesktopTable(context);
  }

  Widget _buildDesktopTable(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB);
    final headerBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9FAFB);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.5),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(headerBg),
              headingRowHeight: 44,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              horizontalMargin: 16,
              columnSpacing: 24,
              columns: columns.map((col) => DataColumn(
                label: Text(col, style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                )),
              )).toList(),
              rows: items.map((item) {
                final values = rowBuilder(item);
                return DataRow(
                  cells: values.map((val) => DataCell(
                    Text(val, style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ), overflow: TextOverflow.ellipsis),
                    onTap: onTap != null ? () => onTap!(item) : null,
                  )).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => mobileCardBuilder!(items[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 12),
            Text(emptyMessage ?? 'No data found.', style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54, fontSize: 14,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 12),
            Text(errorMessage ?? 'An error occurred.', textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}