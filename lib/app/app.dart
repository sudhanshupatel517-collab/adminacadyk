import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/providers/auth_provider.dart';
import '../common/providers/profile_provider.dart';
import '../common/providers/theme_provider.dart';
import 'router/app_router.dart';

class AcadykApp extends StatelessWidget {
  const AcadykApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'Acadyk',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: themeProvider.lightThemeData,
          darkTheme: themeProvider.darkThemeData,
          routerConfig: appRouter,
        );
      },
    );
  }
}