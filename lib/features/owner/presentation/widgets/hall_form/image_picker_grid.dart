import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class ImagePickerGrid extends StatelessWidget {
  final List<String> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxImages;

  const ImagePickerGrid({
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
          return GestureDetector(
            onTap: onAdd,
            child: DottedAddTile(),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Image.asset(images[index], fit: BoxFit.cover),
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

class DottedAddTile extends StatelessWidget {
  const DottedAddTile({super.key});

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
      child: const Center(
        child: Icon(
          Icons.add_a_photo_outlined,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
