import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marriage_hall_app/models/halls/hall_image.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/network_image_box.dart';

/// Create-mode grid: local, not-yet-uploaded photos picked from the
/// gallery. Removable since nothing's been sent to the server yet.
class PickedImagesGrid extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxImages;

  const PickedImagesGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.maxImages = 6,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAddMore = images.length < maxImages;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length + (canAddMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSizes.sm,
        crossAxisSpacing: AppSizes.sm,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index == images.length) {
          return GestureDetector(onTap: onAdd, child: const DottedAddTile());
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Image.file(File(images[index].path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Edit-mode grid: the hall's existing uploaded images, read-only — the
/// backend has no image-delete endpoint. "Add Photos" tile picks new
/// gallery images which get uploaded additively via a separate action.
class ExistingImagesGrid extends StatelessWidget {
  final List<HallImage> images;
  final VoidCallback onAddPhotos;
  final bool isUploading;

  const ExistingImagesGrid({
    super.key,
    required this.images,
    required this.onAddPhotos,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSizes.sm,
        crossAxisSpacing: AppSizes.sm,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index == images.length) {
          return GestureDetector(
            onTap: isUploading ? null : onAddPhotos,
            child: DottedAddTile(
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          );
        }

        final image = images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: NetworkImageBox(url: image.imageUrl),
            ),
            if (image.isPrimary)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Text(
                    "Primary",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DottedAddTile extends StatelessWidget {
  final Widget? child;

  const DottedAddTile({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child:
            child ??
            const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
      ),
    );
  }
}
