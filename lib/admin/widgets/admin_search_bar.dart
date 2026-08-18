import 'package:flutter/material.dart';

/// Clean enterprise search bar with subtle 1px border and crisp input styling.
class AdminSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final List<Widget>? trailing;

  const AdminSearchBar({
    super.key,
    this.hint = 'Search...',
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final hintColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: hintColor, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, size: 17, color: hintColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                isDense: true,
              ),
            ),
          ),
        ),
        if (trailing != null) ...trailing!,
      ],
    );
  }
}