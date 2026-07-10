import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../hall_detail/widgets/about_section.dart';
import '../../../../hall_detail/widgets/hall_image_slider.dart';
import '../widgets/book_photographer_sheet.dart';
import '../widgets/contact_section.dart';
import '../widgets/event_pricing_section.dart';
import '../widgets/package_card.dart';
import '../widgets/photographer_info_section.dart';

class PhotographerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> photographer;
  final bool isFavourite;
  final VoidCallback? onFavouriteToggle;

  const PhotographerProfileScreen({
    super.key,
    required this.photographer,
    this.isFavourite = false,
    this.onFavouriteToggle,
  });

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState extends State<PhotographerProfileScreen> {
  late bool isFavourite = widget.isFavourite;

  void toggleFavourite() {
    setState(() => isFavourite = !isFavourite);
    widget.onFavouriteToggle?.call();
  }

  void openBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BookPhotographerSheet(
        photographerName: widget.photographer['name'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photographer = widget.photographer;
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
              imagePaths: portfolio,
              onBackTap: () => Navigator.pop(context),
              isFavourite: isFavourite,
              onFavouriteTap: toggleFavourite,
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
