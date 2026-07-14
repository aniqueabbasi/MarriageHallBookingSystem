import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_hall_app/screens/booking/booking_screen.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/controllers/favorites/favorites_controller.dart';
import 'package:marriage_hall_app/widgets/reviews/reviews_summary_section.dart';
import 'package:marriage_hall_app/widgets/virtual_tour/virtual_tour_card.dart';
import 'package:marriage_hall_app/widgets/halls/about_section.dart';
import 'package:marriage_hall_app/widgets/halls/amenities_section.dart';
import 'package:marriage_hall_app/widgets/halls/book_now_button.dart';
import 'package:marriage_hall_app/widgets/halls/hall_image_slider.dart';
import 'package:marriage_hall_app/widgets/halls/hall_info_section.dart';
import 'package:marriage_hall_app/screens/halls/hall_gallery_screen.dart';

class HallDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> hall;

  const HallDetailScreen({super.key, required this.hall});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String hallId = hall['id'];
    final isFavourite = ref.watch(
      favoritesControllerProvider.select((s) => s.hallIds.contains(hallId)),
    );
    final List<String> galleryImages = List<String>.from(
      (hall['images'] as List?) ?? [hall['imagePath']],
    );
    final List<String> sliderImages = galleryImages.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: BookNowButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingScreen(hall: hall)),
          );
        },
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            HallImageSlider(
              sliderId: 'hall_$hallId',
              imagePaths: sliderImages,
              onBackTap: () {
                Navigator.pop(context);
              },
              isFavourite: isFavourite,
              onFavouriteTap: () => ref
                  .read(favoritesControllerProvider.notifier)
                  .toggleHall(hallId),
              onGalleryTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HallGalleryScreen(
                      hallName: hall['hallName'],
                      images: galleryImages,
                    ),
                  ),
                );
              },
            ),

            if ((hall['virtualTourImage'] as String?)?.isNotEmpty == true)
              VirtualTourCard(
                hallName: hall['hallName'],
                panoramaImage: hall['virtualTourImage'],
              ),

            HallInfoSection(
              hallName: hall['hallName'],
              location: hall['location'],
              rating: hall['rating'],
              reviews: hall['reviews'],
              capacity: hall['capacity'],
              price: hall['price'],
            ),

            const AmenitiesSection(
              amenities: [
                'Parking',
                'AC',
                'Catering',
                'Generator',
                'Stage',
                'Bridal Room',
              ],
            ),

            const AboutSection(
              description:
                  'A spacious and elegant marriage hall with beautiful decoration, comfortable seating, air conditioning, catering service, parking facility, and professional staff. Best for weddings, engagements, receptions, and family events.',
            ),

            ReviewsSummarySection(
              hallName: hall['hallName'],
              rating: hall['rating'] ?? 0,
              reviewsCount: hall['reviews'] ?? 0,
              ratingBreakdown: Map<int, int>.from(
                (hall['ratingBreakdown'] as Map?) ?? const {},
              ),
              canWriteReview: hall['canWriteReview'] == true,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
