import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/controllers/cnic/cnic_scan_controller.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/cnic/cnic_source_sheet.dart';

/// Shared by the initial "Scan CNIC" entry point and the verification
/// screen's "Retake" action: shows the source sheet, then a blocking
/// "Reading CNIC…" dialog while the pick + on-device OCR run. Does
/// nothing if the user backs out of either step.
Future<void> runCnicPickAndScan({
  required BuildContext context,
  required WidgetRef ref,
  required String instanceId,
}) async {
  final source = await showModalBottomSheet<CnicImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const CnicSourceSheet(),
  );
  if (source == null || !context.mounted) return;

  final notifier = ref.read(cnicScanControllerProvider(instanceId).notifier);

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ScanningDialog(),
    ),
  );

  if (source == CnicImageSource.camera) {
    await notifier.pickFromCamera();
  } else {
    await notifier.pickFromGallery();
  }

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _ScanningDialog extends StatelessWidget {
  const _ScanningDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSizes.md),
              Text(
                "Reading CNIC…",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
