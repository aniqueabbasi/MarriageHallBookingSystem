import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

class AboutSection extends StatelessWidget {
  final String description;

  const AboutSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: AppSizes.sm),

          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
