import 'package:flutter/material.dart';
import 'package:marriage_hall_app/features/booking/presentation/screens/booking_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../features/reviews/presentation/widgets/reviews_summary_section.dart';
import '../../features/virtual_tour/presentation/widgets/virtual_tour_card.dart';
import '../widgets/about_section.dart';
import '../widgets/amenities_section.dart';
import '../widgets/book_now_button.dart';
import '../widgets/hall_image_slider.dart';
import '../widgets/hall_info_section.dart';
import 'hall_gallery_screen.dart';

class HallDetailScreen extends StatefulWidget {
  final Map<String, dynamic> hall;
  final bool isFavourite;
  final VoidCallback? onFavouriteToggle;

  const HallDetailScreen({
    super.key,
    required this.hall,
    this.isFavourite = false,
    this.onFavouriteToggle,
  });

  @override
  State<HallDetailScreen> createState() => _HallDetailScreenState();
}

class _HallDetailScreenState extends State<HallDetailScreen> {
  late bool isFavourite = widget.isFavourite;

  void toggleFavourite() {
    setState(() => isFavourite = !isFavourite);
    widget.onFavouriteToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hall = widget.hall;
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
              imagePaths: sliderImages,
              onBackTap: () {
                Navigator.pop(context);
              },
              isFavourite: isFavourite,
              onFavouriteTap: toggleFavourite,
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
