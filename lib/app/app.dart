import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class TutorMateApp extends StatelessWidget {
  const TutorMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TutorMate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
