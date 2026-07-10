import 'package:flutter/material.dart';
import 'package:marriage_hall_app/core/Themes/app_theme.dart';

import 'core/routes/app_router.dart';

class MarriageHallApp extends StatelessWidget {
  const MarriageHallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hall & Feast',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
