import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ContactSection extends StatelessWidget {
  final String phone;
  final String email;
  final String instagram;

  const ContactSection({
    super.key,
    required this.phone,
    required this.email,
    required this.instagram,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContactRow(icon: Icons.phone_outlined, label: phone),
        _ContactRow(icon: Icons.email_outlined, label: email),
        _ContactRow(icon: Icons.camera_alt_outlined, label: instagram),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSizes.sm),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
