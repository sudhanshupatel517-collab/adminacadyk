import 'package:flutter/material.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminMediaScreen extends StatefulWidget {
  const AdminMediaScreen({super.key});

  @override
  State<AdminMediaScreen> createState() => _AdminMediaScreenState();
}

class _AdminMediaScreenState extends State<AdminMediaScreen> {
  final List<Map<String, String>> _mediaItems = [
    {'name': 'lagacy.png', 'path': 'assets/images/lagacy.png', 'size': '497 KB', 'type': 'Brand Logo'},
    {'name': 'acadyk_logo.png', 'path': 'assets/images/acadyk_logo.png', 'size': '41 KB', 'type': 'Legacy Logo'},
    {'name': 'mits_logo.png', 'path': 'assets/images/mits_logo.png', 'size': '35 KB', 'type': 'Partner Logo'},
    {'name': 'ocean_wave_header.png', 'path': 'assets/images/ocean_wave_header.png', 'size': '975 KB', 'type': 'Banner'},
    {'name': 'team_celebration_banner.png', 'path': 'assets/images/team_celebration_banner.png', 'size': '805 KB', 'type': 'Banner'},
    {'name': 'young_entrepreneur.jpg', 'path': 'assets/images/young_entrepreneur.jpg', 'size': '798 KB', 'type': 'Hero Graphic'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(
            title: 'Media Asset Repository',
            padding: const EdgeInsets.only(bottom: 16),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Asset management is synchronized with local assets directory.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.brand,
                foregroundColor: isDark ? AppColors.brand : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              child: const Text('Upload Asset'),
            ),
          ),
          AdminSearchBar(
            hint: 'Search media assets...',
            onChanged: (q) {},
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemCount: _mediaItems.length,
                itemBuilder: (context, index) {
                  final item = _mediaItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(isDark),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: AppColors.surfaceAlt(isDark),
                            child: Center(
                              child: Image.asset(
                                item['path']!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Text('Asset Not Found', style: TextStyle(color: AppColors.textMut(isDark), fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: AppColors.text(isDark),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['type']} · ${item['size']}',
                                style: TextStyle(fontSize: 11, color: AppColors.textMut(isDark)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}