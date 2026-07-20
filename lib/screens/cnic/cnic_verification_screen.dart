import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/controllers/cnic/cnic_scan_controller.dart';
import 'package:marriage_hall_app/models/cnic/cnic_details.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/utils/cnic_parser.dart';
import 'package:marriage_hall_app/widgets/booking/date_picker_field.dart';
import 'package:marriage_hall_app/widgets/cnic/cnic_scan_flow.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

const _genderOptions = ['Male', 'Female', 'Other'];

/// Lets the user review and correct every OCR-extracted CNIC field before
/// anything is submitted. Nothing here is saved until the user explicitly
/// confirms — the image itself is only ever shown as a temporary preview
/// and is never part of the submitted request.
class CnicVerificationScreen extends ConsumerStatefulWidget {
  final String instanceId;

  const CnicVerificationScreen({super.key, required this.instanceId});

  @override
  ConsumerState<CnicVerificationScreen> createState() =>
      _CnicVerificationScreenState();
}

class _CnicVerificationScreenState
    extends ConsumerState<CnicVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final cnicNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final fatherNameController = TextEditingController();

  DateTime? dateOfBirth;
  DateTime? dateOfIssue;
  DateTime? dateOfExpiry;
  String? gender;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    final details = ref.read(
      cnicScanControllerProvider(widget.instanceId),
    ).extractedDetails;
    if (details != null) _syncFieldsFrom(details);
  }

  void _syncFieldsFrom(CnicDetails details) {
    cnicNumberController.text = details.cnicNumber;
    fullNameController.text = details.fullName;
    fatherNameController.text = details.fatherOrHusbandName;
    setState(() {
      dateOfBirth = details.dateOfBirth;
      dateOfIssue = details.dateOfIssue;
      dateOfExpiry = details.dateOfExpiry;
      gender = details.gender;
    });
  }

  @override
  void dispose() {
    cnicNumberController.dispose();
    fullNameController.dispose();
    fatherNameController.dispose();
    super.dispose();
  }

  CnicDetails _currentDetailsFromForm() => CnicDetails(
    cnicNumber: cnicNumberController.text.trim(),
    fullName: fullNameController.text.trim(),
    fatherOrHusbandName: fatherNameController.text.trim(),
    dateOfBirth: dateOfBirth,
    dateOfIssue: dateOfIssue,
    dateOfExpiry: dateOfExpiry,
    gender: gender,
  );

  Future<void> retake() async {
    await runCnicPickAndScan(
      context: context,
      ref: ref,
      instanceId: widget.instanceId,
    );
  }

  Future<void> submit() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    if (dateOfBirth == null || dateOfIssue == null || dateOfExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all three CNIC dates.')),
      );
      return;
    }
    if (!confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm the details are correct.'),
        ),
      );
      return;
    }

    final notifier = ref.read(
      cnicScanControllerProvider(widget.instanceId).notifier,
    );
    notifier.updateExtractedDetails(_currentDetailsFromForm());
    final success = await notifier.submitCnicDetails();

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      final message = ref
          .read(cnicScanControllerProvider(widget.instanceId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not save your CNIC details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CnicScanState>(cnicScanControllerProvider(widget.instanceId), (
      previous,
      next,
    ) {
      if (next.extractedDetails != null &&
          next.extractedDetails != previous?.extractedDetails) {
        _syncFieldsFrom(next.extractedDetails!);
      }
    });

    final scanState = ref.watch(cnicScanControllerProvider(widget.instanceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Verify CNIC Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scanState.selectedImagePath != null)
                _ImagePreview(
                  imagePath: scanState.selectedImagePath!,
                  onRetake: retake,
                ),
              const SizedBox(height: AppSizes.md),
              if (scanState.errorMessage != null) ...[
                _ErrorBanner(message: scanState.errorMessage!),
                const SizedBox(height: AppSizes.md),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        "Please verify the extracted information before "
                        "continuing.",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              TextFormField(
                controller: cnicNumberController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "CNIC Number",
                  hintText: "XXXXX-XXXXXXX-X",
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return "CNIC number is required";
                  if (!isValidCnicFormat(trimmed)) {
                    return "Enter a valid CNIC in the format XXXXX-XXXXXXX-X";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? "Name is required"
                    : null,
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: fatherNameController,
                decoration: const InputDecoration(
                  labelText: "Father / Husband Name",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? "This field is required"
                    : null,
              ),
              const SizedBox(height: AppSizes.md),
              DatePickerField(
                selectedDate: dateOfBirth,
                hintText: "Date of Birth",
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onDateChanged: (date) => setState(() => dateOfBirth = date),
              ),
              const SizedBox(height: AppSizes.md),
              DatePickerField(
                selectedDate: dateOfIssue,
                hintText: "Date of Issue",
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
                onDateChanged: (date) => setState(() => dateOfIssue = date),
              ),
              const SizedBox(height: AppSizes.md),
              DatePickerField(
                selectedDate: dateOfExpiry,
                hintText: "Date of Expiry",
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                onDateChanged: (date) => setState(() => dateOfExpiry = date),
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: const InputDecoration(
                  labelText: "Gender (optional)",
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: [
                  for (final option in _genderOptions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) => setState(() => gender = value),
              ),
              const SizedBox(height: AppSizes.lg),
              CheckboxListTile(
                value: confirmed,
                onChanged: (value) =>
                    setState(() => confirmed = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "I confirm the above details are correct.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              GradientButton(
                label: scanState.isSubmitting ? "Saving..." : "Confirm & Continue",
                icon: Icons.check_circle_outline,
                onPressed: (scanState.isScanning || scanState.isSubmitting)
                    ? null
                    : submit,
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRetake;

  const _ImagePreview({required this.imagePath, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Image.file(
            File(imagePath),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRetake,
            icon: const Icon(Icons.replay_outlined, size: 18),
            label: const Text("Retake"),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_outlined, color: AppColors.error),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
