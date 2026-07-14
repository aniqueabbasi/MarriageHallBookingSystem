import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/halls/city_filter_chip.dart';

final citySheetSelectionProvider = StateProvider.autoDispose
    .family<String, String>((ref, initialCity) => initialCity);

class CityFilterSheet extends ConsumerWidget {
  final String selectedCity;
  final List<String> cities;

  const CityFilterSheet({
    super.key,
    required this.selectedCity,
    required this.cities,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionProvider = citySheetSelectionProvider(selectedCity);
    final currentSelection = ref.watch(selectionProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text(
            AppStrings.filterByCity,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: 0,
            runSpacing: AppSizes.sm,
            children: cities.map((city) {
              return CityFilterChip(
                cityName: city,
                isSelected: currentSelection == city,
                onTap: () => ref.read(selectionProvider.notifier).state = city,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),
          GradientButton(
            label: AppStrings.apply,
            icon: Icons.check,
            onPressed: () => Navigator.pop(context, currentSelection),
          ),
        ],
      ),
    );
  }
}
