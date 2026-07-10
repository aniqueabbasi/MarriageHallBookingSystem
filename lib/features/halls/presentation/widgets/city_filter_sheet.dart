import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/gradient_button.dart';
import 'city_filter_chip.dart';

class CityFilterSheet extends StatefulWidget {
  final String selectedCity;
  final List<String> cities;

  const CityFilterSheet({
    super.key,
    required this.selectedCity,
    required this.cities,
  });

  @override
  State<CityFilterSheet> createState() => _CityFilterSheetState();
}

class _CityFilterSheetState extends State<CityFilterSheet> {
  late String selectedCity = widget.selectedCity;

  @override
  Widget build(BuildContext context) {
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
            children: widget.cities.map((city) {
              return CityFilterChip(
                cityName: city,
                isSelected: selectedCity == city,
                onTap: () => setState(() => selectedCity = city),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),
          GradientButton(
            label: AppStrings.apply,
            icon: Icons.check,
            onPressed: () => Navigator.pop(context, selectedCity),
          ),
        ],
      ),
    );
  }
}
