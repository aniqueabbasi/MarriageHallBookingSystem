import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/shared/section_card.dart';
import 'package:marriage_hall_app/widgets/halls/about_section.dart';
import 'package:marriage_hall_app/widgets/halls/hall_image_slider.dart';
import 'package:marriage_hall_app/controllers/favorites/favorites_controller.dart';
import 'package:marriage_hall_app/widgets/photographers/book_photographer_sheet.dart';
import 'package:marriage_hall_app/widgets/photographers/contact_section.dart';
import 'package:marriage_hall_app/widgets/photographers/event_pricing_section.dart';
import 'package:marriage_hall_app/widgets/photographers/package_card.dart';
import 'package:marriage_hall_app/widgets/photographers/photographer_info_section.dart';

class PhotographerProfileScreen extends ConsumerWidget {
  final Map<String, dynamic> photographer;

  const PhotographerProfileScreen({super.key, required this.photographer});

  void openBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          BookPhotographerSheet(photographerName: photographer['name']),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String photographerId = photographer['id'];
    final isFavourite = ref.watch(
      favoritesControllerProvider.select(
        (s) => s.photographerIds.contains(photographerId),
      ),
    );
    final packages = List<Map<String, dynamic>>.from(
      photographer['packages'] as List,
    );
    final eventPricing = List<Map<String, dynamic>>.from(
      photographer['eventPricing'] as List,
    );
    final portfolio = List<String>.from(photographer['portfolio'] as List);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GradientButton(
            label: "Book Photographer",
            icon: Icons.camera_alt_outlined,
            onPressed: () => openBookingSheet(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HallImageSlider(
              sliderId: 'photographer_$photographerId',
              imagePaths: portfolio,
              onBackTap: () => Navigator.pop(context),
              isFavourite: isFavourite,
              onFavouriteTap: () => ref
                  .read(favoritesControllerProvider.notifier)
                  .togglePhotographer(photographerId),
            ),
            PhotographerInfoSection(
              name: photographer['name'],
              specialty: photographer['specialty'],
              city: photographer['city'],
              experience: photographer['experience'],
              rating: photographer['rating'],
              reviews: photographer['reviews'],
              startingPrice: photographer['startingPrice'],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SectionCard(
                    icon: Icons.card_membership_outlined,
                    title: "Packages",
                    child: Column(
                      children: packages
                          .map((package) => PackageCard(package: package))
                          .toList(),
                    ),
                  ),
                  SectionCard(
                    icon: Icons.payments_outlined,
                    title: "Pricing By Event",
                    child: EventPricingSection(eventPricing: eventPricing),
                  ),
                  SectionCard(
                    icon: Icons.contact_phone_outlined,
                    title: "Contact Information",
                    child: ContactSection(
                      phone: photographer['phone'],
                      email: photographer['email'],
                      instagram: photographer['instagram'],
                    ),
                  ),
                ],
              ),
            ),
            AboutSection(description: photographer['description']),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
