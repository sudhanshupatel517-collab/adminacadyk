import 'package:flutter/material.dart';

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
    final bgColor = isDark ? const Color(0xFF111111) : const Color(0xFFF3F4F6);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 20, color: isDark ? Colors.white38 : Colors.black38),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        if (trailing != null) ...trailing!,
      ],
    );
  }
}