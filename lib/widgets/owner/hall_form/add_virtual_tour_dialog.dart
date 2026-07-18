import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/controllers/halls/virtual_tour_controller.dart';
import 'package:marriage_hall_app/models/halls/create_virtual_tour_request.dart';
import 'package:marriage_hall_app/models/halls/virtual_tour_info.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

bool _isValidTourUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}

/// Pops with the created [VirtualTourInfo] on success; stays open on
/// failure so the owner doesn't lose their input.
class AddVirtualTourDialog extends ConsumerStatefulWidget {
  final int hallId;

  const AddVirtualTourDialog({super.key, required this.hallId});

  @override
  ConsumerState<AddVirtualTourDialog> createState() =>
      _AddVirtualTourDialogState();
}

class _AddVirtualTourDialogState extends ConsumerState<AddVirtualTourDialog> {
  final titleController = TextEditingController();
  final tourUrlController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    titleController.dispose();
    tourUrlController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final title = titleController.text.trim();
    final tourUrl = tourUrlController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorText = "Title is required");
      return;
    }
    if (tourUrl.isEmpty) {
      setState(() => _errorText = "Tour URL is required");
      return;
    }
    if (!_isValidTourUrl(tourUrl)) {
      setState(
        () => _errorText = "Enter a valid link starting with http:// or https://",
      );
      return;
    }

    setState(() => _errorText = null);

    final tour = await ref
        .read(virtualTourControllerProvider(widget.hallId).notifier)
        .addTour(
          widget.hallId,
          CreateVirtualTourRequest(title: title, tourUrl: tourUrl),
        );

    if (!mounted) return;

    if (tour == null) {
      final message = ref
          .read(virtualTourControllerProvider(widget.hallId))
          .errorMessage;
      setState(() => _errorText = message ?? "Could not add virtual tour");
      return;
    }

    Navigator.pop(context, tour);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      virtualTourControllerProvider(widget.hallId).select((s) => s.isLoading),
    );

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
              "Add Virtual Tour",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                hintText: "e.g. Main Hall 360° View",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: tourUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: "Tour URL",
                hintText: "https://example.com/tour.jpg",
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
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: GradientButton(
                    label: isSaving ? "Adding..." : "Add",
                    onPressed: isSaving ? null : save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
