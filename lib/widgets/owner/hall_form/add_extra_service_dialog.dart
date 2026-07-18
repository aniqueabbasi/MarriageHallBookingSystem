import 'package:flutter/material.dart';

import 'package:marriage_hall_app/models/halls/create_extra_service_request.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

/// Pure data-entry dialog — pops with a [CreateExtraServiceRequest] once
/// the fields validate. Doesn't touch the network itself: the caller
/// decides whether that means staging it locally (create mode) or folding
/// it into an immediate full-hall update (edit mode, since the backend
/// only takes extra services via the create/update multipart endpoints
/// now).
class AddExtraServiceDialog extends StatefulWidget {
  const AddExtraServiceDialog({super.key});

  @override
  State<AddExtraServiceDialog> createState() => _AddExtraServiceDialogState();
}

class _AddExtraServiceDialogState extends State<AddExtraServiceDialog> {
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
      setState(() => _errorText = "Service name is required");
      return;
    }
    if (description.isEmpty) {
      setState(() => _errorText = "Description is required");
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _errorText = "Enter a valid price");
      return;
    }

    Navigator.pop(
      context,
      CreateExtraServiceRequest(
        name: name,
        description: description,
        price: price,
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
              "Add Custom Service",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Service Name",
                hintText: "e.g. Decoration",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Description *",
                hintText: "What's included in this service",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price (PKR)",
                hintText: "5000",
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
