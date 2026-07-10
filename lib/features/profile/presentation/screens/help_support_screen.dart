import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const faqs = [
    {
      'question': 'How do I book a marriage hall?',
      'answer':
          'Browse halls from the Home tab, open a hall\'s profile and tap "Book Now" to send a booking request.',
    },
    {
      'question': 'How do I book a photographer?',
      'answer':
          'Switch to the Photographer category on Home, open a photographer\'s profile and tap "Book Photographer".',
    },
    {
      'question': 'Can I cancel a booking?',
      'answer':
          'Cancellation depends on the hall owner or photographer\'s policy. Contact them directly using the details on their profile.',
    },
    {
      'question': 'How do I save a hall or photographer for later?',
      'answer':
          'Tap the heart icon on any hall or photographer card, or on their profile screen, to add them to your Favorites tab.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Help & Support"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.md),
          ...faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.primary,
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    0,
                    AppSizes.md,
                    AppSizes.md,
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq['answer']!,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSizes.lg),
          const Text(
            "Contact Support",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.md),
          _ContactRow(icon: Icons.phone_outlined, label: "0300 1234567"),
          _ContactRow(icon: Icons.email_outlined, label: "support@hallandfeast.com"),
          _ContactRow(icon: Icons.chat_outlined, label: "WhatsApp: 0300 1234567"),
        ],
      ),
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
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
