import 'package:flutter/material.dart';
import '../widgets/admin_search_bar.dart';

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
    final borderColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AdminSearchBar(
                  hint: 'Search media assets...',
                  onChanged: (q) {},
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Asset management is synchronized with local assets directory.')),
                  );
                },
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload Asset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _mediaItems.length,
                itemBuilder: (context, index) {
                  final item = _mediaItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111111) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: isDark ? Colors.black : const Color(0xFFF3F4F6),
                            child: Center(
                              child: Image.asset(
                                item['path']!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : Colors.black), overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('${item['type']} \u2022 ${item['size']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert, size: 18, color: isDark ? Colors.white54 : Colors.black45),
                                onPressed: () {},
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