import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7B1E3D);
  static const Color primaryDark = Color(0xFF4A1226);
  static const Color primaryLight = Color(0xFFA43A5C);

  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFE9CC6E);

  static const Color background = Color(0xFFFAF6F3);
  static const Color card = Colors.white;
  static const Color chipBackground = Color(0xFFF3ECDD);

  static const Color textPrimary = Color(0xFF201417);
  static const Color textSecondary = Color(0xFF767178);

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFB8760A);

  static const Color border = Color(0xFFEDE4E7);

  static const Color star = Colors.amber;

  // Splash (matches the Hall & Feast logo artwork background)
  static const Color splashBackground = Color(0xFF0E2A2D);
  static const Color splashBackgroundDark = Color(0xFF071718);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );
}
