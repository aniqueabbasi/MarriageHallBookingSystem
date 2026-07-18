import 'package:flutter/material.dart';

import 'package:marriage_hall_app/models/halls/create_food_package_request.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

/// Pure data-entry dialog — pops with a [CreateFoodPackageRequest] once the
/// fields validate. Doesn't touch the network itself: the caller decides
/// whether that means staging it locally (create mode) or folding it into
/// an immediate full-hall update (edit mode, since the backend only takes
/// food packages via the create/update multipart endpoints now).
class AddFoodPackageDialog extends StatefulWidget {
  const AddFoodPackageDialog({super.key});

  @override
  State<AddFoodPackageDialog> createState() => _AddFoodPackageDialogState();
}

class _AddFoodPackageDialogState extends State<AddFoodPackageDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty) {
      setState(() => _errorText = "Package name is required");
      return;
    }
    if (description.isEmpty) {
      setState(() => _errorText = "Description is required");
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _errorText = "Enter a valid price per head");
      return;
    }

    Navigator.pop(
      context,
      CreateFoodPackageRequest(
        name: name,
        description: description,
        pricePerHead: price,
      ),
    );
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
              controller: descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Description *",
                hintText: "Chicken Karahi, Biryani, Sweet Dish",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price Per Head (PKR)",
                hintText: "1500",
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                _errorText!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
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
                Expanded(child: GradientButton(label: "Add", onPressed: save)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
