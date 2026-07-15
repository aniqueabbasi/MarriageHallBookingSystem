import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import 'package:marriage_hall_app/resources/app_sizes.dart';

class VirtualTourScreen extends StatelessWidget {
  final String hallName;
  final String tourUrl;

  const VirtualTourScreen({
    super.key,
    required this.hallName,
    required this.tourUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PanoramaViewer(child: Image.network(tourUrl)),
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
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        hallName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSizes.xl,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.threesixty, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Drag to look around",
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
