import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';

/// Renders a hall/gallery image from a URL, with a placeholder for a
/// missing/null URL and a broken-image fallback for a failed load — every
/// hall image now comes from the backend rather than a bundled asset.
class NetworkImageBox extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _placeholder(Icons.villa_outlined);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(null, loading: true);
      },
      errorBuilder: (context, error, stack) =>
          _placeholder(Icons.broken_image_outlined),
    );
  }

  Widget _placeholder(IconData? icon, {bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.chipBackground,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: AppColors.primary, size: 36),
    );
  }
}
