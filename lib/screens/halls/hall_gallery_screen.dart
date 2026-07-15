import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/network_image_box.dart';

class HallGalleryScreen extends StatelessWidget {
  final String hallName;
  final List<String> images;

  const HallGalleryScreen({
    super.key,
    required this.hallName,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(hallName),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSizes.sm),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSizes.sm,
          crossAxisSpacing: AppSizes.sm,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _GalleryViewerScreen(
                    galleryId: hallName,
                    images: images,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: NetworkImageBox(url: images[index]),
            ),
          );
        },
      ),
    );
  }
}

final _galleryViewerIndexProvider = StateProvider.autoDispose
    .family<int, (String, int)>((ref, key) => key.$2);

class _GalleryViewerScreen extends ConsumerStatefulWidget {
  final String galleryId;
  final List<String> images;
  final int initialIndex;

  const _GalleryViewerScreen({
    required this.galleryId,
    required this.images,
    required this.initialIndex,
  });

  @override
  ConsumerState<_GalleryViewerScreen> createState() =>
      _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends ConsumerState<_GalleryViewerScreen> {
  late final PageController controller = PageController(
    initialPage: widget.initialIndex,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indexProvider = _galleryViewerIndexProvider((
      widget.galleryId,
      widget.initialIndex,
    ));
    final currentIndex = ref.watch(indexProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (index) =>
                  ref.read(indexProvider.notifier).state = index,
              itemBuilder: (context, index) => InteractiveViewer(
                child: Center(
                  child: NetworkImageBox(
                    url: widget.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      ),
                      child: Text(
                        "${currentIndex + 1} / ${widget.images.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
