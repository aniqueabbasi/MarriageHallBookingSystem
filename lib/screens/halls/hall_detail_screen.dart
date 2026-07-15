import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_hall_app/screens/booking/booking_screen.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/controllers/favorites/favorites_controller.dart';
import 'package:marriage_hall_app/controllers/halls/hall_detail_controller.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/reviews/reviews_summary_section.dart';
import 'package:marriage_hall_app/widgets/virtual_tour/virtual_tour_card.dart';
import 'package:marriage_hall_app/widgets/halls/about_section.dart';
import 'package:marriage_hall_app/widgets/halls/amenities_section.dart';
import 'package:marriage_hall_app/widgets/halls/book_now_button.dart';
import 'package:marriage_hall_app/widgets/halls/hall_image_slider.dart';
import 'package:marriage_hall_app/widgets/halls/hall_info_section.dart';
import 'package:marriage_hall_app/screens/halls/hall_gallery_screen.dart';

class HallDetailScreen extends ConsumerWidget {
  final int hallId;

  const HallDetailScreen({super.key, required this.hallId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallAsync = ref.watch(hallDetailProvider(hallId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: hallAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load this hall: ${error.toString()}'),
          ),
        ),
        data: (hall) => _HallDetailBody(hall: hall),
      ),
    );
  }
}

class _HallDetailBody extends ConsumerWidget {
  final Hall hall;

  const _HallDetailBody({required this.hall});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallIdString = hall.id.toString();
    final isFavourite = ref.watch(
      favoritesControllerProvider.select((s) => s.hallIds.contains(hallIdString)),
    );
    final imageUrls = hall.images.map((i) => i.imageUrl).toList();
    final sliderImages = imageUrls.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: BookNowButton(
        onPressed: hall.isActive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(hall: hall),
                  ),
                );
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'This hall is not currently accepting bookings.',
                    ),
                  ),
                );
              },
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            HallImageSlider(
              sliderId: 'hall_${hall.id}',
              imagePaths: sliderImages,
              onBackTap: () {
                Navigator.pop(context);
              },
              isFavourite: isFavourite,
              onFavouriteTap: () => ref
                  .read(favoritesControllerProvider.notifier)
                  .toggleHall(hallIdString),
              onGalleryTap: imageUrls.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HallGalleryScreen(
                            hallName: hall.name,
                            images: imageUrls,
                          ),
                        ),
                      );
                    },
            ),

            if (hall.virtualTours.isNotEmpty)
              VirtualTourCard(
                hallName: hall.name,
                tourUrl: hall.virtualTours.first.tourUrl,
              ),

            HallInfoSection(
              hallName: hall.name,
              location: '${hall.address}, ${hall.city}',
              rating: hall.averageRating,
              reviews: hall.reviewCount,
              capacity: 'Up to ${hall.capacity} Guests',
              price: formatPkr(hall.pricePerDay),
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

            AboutSection(
              description: hall.description.isEmpty
                  ? 'No description provided for this hall yet.'
                  : hall.description,
            ),

            ReviewsSummarySection(
              hallName: hall.name,
              rating: hall.averageRating,
              reviewsCount: hall.reviewCount,
              ratingBreakdown: const {},
              canWriteReview: false,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
