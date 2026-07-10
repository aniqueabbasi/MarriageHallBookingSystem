import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HallImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final VoidCallback onBackTap;
  final VoidCallback onFavouriteTap;
  final bool isFavourite;
  final VoidCallback? onGalleryTap;

  const HallImageSlider({
    super.key,
    required this.imagePaths,
    required this.onBackTap,
    required this.onFavouriteTap,
    this.isFavourite = false,
    this.onGalleryTap,
  });

  @override
  State<HallImageSlider> createState() => _HallImageSliderState();
}

class _HallImageSliderState extends State<HallImageSlider> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 360,
          width: double.infinity,
          child: PageView.builder(
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(widget.imagePaths[index], fit: BoxFit.cover);
            },
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 45,
          left: 20,
          child: _RoundIconButton(
            icon: Icons.arrow_back,
            onTap: widget.onBackTap,
          ),
        ),

        Positioned(
          top: 45,
          right: 20,
          child: _RoundIconButton(
            icon: widget.isFavourite ? Icons.favorite : Icons.favorite_border,
            iconColor: widget.isFavourite ? Colors.red : AppColors.primary,
            onTap: widget.onFavouriteTap,
          ),
        ),

        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imagePaths.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentIndex == index ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColors.secondary
                      : Colors.white70,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
        ),

        if (widget.onGalleryTap != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: widget.onGalleryTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "View Gallery",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor ?? AppColors.primary),
      ),
    );
  }
}
