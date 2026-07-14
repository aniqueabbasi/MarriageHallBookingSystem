import 'package:flutter/material.dart';
import 'package:marriage_hall_app/resources/app_theme.dart';

import 'package:marriage_hall_app/app_router.dart';

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
