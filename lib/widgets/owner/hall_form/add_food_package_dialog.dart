import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

class AddFoodPackageDialog extends StatefulWidget {
  const AddFoodPackageDialog({super.key});

  @override
  State<AddFoodPackageDialog> createState() => _AddFoodPackageDialogState();
}

class _AddFoodPackageDialogState extends State<AddFoodPackageDialog> {
  final nameController = TextEditingController();
  final itemsController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    itemsController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void save() {
    if (nameController.text.trim().isEmpty) return;

    final items = itemsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    Navigator.pop(context, {
      'name': nameController.text.trim(),
      'items': items,
      'pricePerPerson': priceController.text.trim().isEmpty
          ? '0'
          : priceController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Food Package",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Package Name",
                hintText: "e.g. Deluxe Package",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: itemsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Items (comma separated)",
                hintText: "Chicken Karahi, Biryani, Sweet Dish",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price Per Person (PKR)",
                hintText: "1500",
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: GradientButton(label: "Add", onPressed: save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
