import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class LegalPageScaffold extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> sections;

  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections.map((section) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    section.value,
                    style: const TextStyle(height: 1.5, color: AppColors.textPrimary),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
