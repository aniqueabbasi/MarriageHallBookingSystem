import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/constants/hall_status.dart';
import 'package:marriage_hall_app/constants/lists.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/screens/virtual_tour/virtual_tour_screen.dart';
import 'package:marriage_hall_app/controllers/halls/create_hall_controller.dart';
import 'package:marriage_hall_app/controllers/halls/hall_form_controller.dart';
import 'package:marriage_hall_app/models/halls/create_hall_request.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/add_food_package_dialog.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/availability_calendar_preview.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/day_selector.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/extra_service_row.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/food_package_card.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/image_picker_grid.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/labeled_text_field.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/section_card.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/stepper_field.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/toggle_row.dart';

const List<Map<String, String>> hallTimeSlots = [
  {'id': 'day', 'label': 'Day Slot', 'time': '12:00 PM - 5:00 PM'},
  {'id': 'evening', 'label': 'Evening Slot', 'time': '6:00 PM - 10:00 PM'},
];

class AddEditHallScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialHall;

  const AddEditHallScreen({super.key, this.initialHall});

  bool get isEditMode => initialHall != null;

  @override
  ConsumerState<AddEditHallScreen> createState() => _AddEditHallScreenState();
}

class _AddEditHallScreenState extends ConsumerState<AddEditHallScreen> {
  Map<String, dynamic> get _hall => widget.initialHall ?? const {};

  bool get _isResubmission => _hall['status'] == HallStatus.rejected;

  late final HallFormKey _formKey = (UniqueKey().toString(), widget.initialHall);

  // Basic Information
  late final nameController = TextEditingController(
    text: _hall['hallName'] ?? '',
  );
  late final descriptionController = TextEditingController(
    text: _hall['description'] ?? '',
  );
  late final addressController = TextEditingController(
    text: _hall['address'] ?? '',
  );

  // Hall Details
  late final capacityController = TextEditingController(
    text: _hall['capacity'] ?? '',
  );
  late final priceController = TextEditingController(
    text: _hall['price'] ?? '',
  );
  late final pricePerPersonController = TextEditingController(
    text: _hall['pricePerPerson'] ?? '',
  );

  // Contact Information
  late final ownerNameController = TextEditingController(
    text: _hall['ownerName'] ?? '',
  );
  late final phoneController = TextEditingController(
    text: _hall['phone'] ?? '',
  );
  late final whatsappController = TextEditingController(
    text: _hall['whatsapp'] ?? '',
  );
  late final emailController = TextEditingController(
    text: _hall['email'] ?? '',
  );

  final Map<String, TextEditingController> _extraServicePriceControllers = {};

  TextEditingController _priceControllerFor(String serviceName) {
    return _extraServicePriceControllers.putIfAbsent(serviceName, () {
      final existing = List<Map<String, dynamic>>.from(
        (_hall['extraServices'] as List?) ?? const [],
      );
      final match = existing.where((e) => e['name'] == serviceName);
      final price = match.isEmpty ? '' : '${match.first['price'] ?? ''}';
      return TextEditingController(text: price);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    capacityController.dispose();
    priceController.dispose();
    pricePerPersonController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    emailController.dispose();
    for (final controller in _extraServicePriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> addFoodPackage() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddFoodPackageDialog(),
    );

    if (result != null) {
      ref.read(hallFormControllerProvider(_formKey).notifier).addFoodPackage(result);
    }
  }

  Future<void> addCustomService() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Service Name"),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price (PKR)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final name = nameController.text.trim();
      ref.read(hallFormControllerProvider(_formKey).notifier).addExtraService(name);
      _extraServicePriceControllers[name] = TextEditingController(
        text: priceController.text.trim(),
      );
    }
  }

  void addImage() {
    final formState = ref.read(hallFormControllerProvider(_formKey));
    if (formState.images.length >= hallFormMaxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can add up to 6 images only.")),
      );
      return;
    }

    final next =
        hallFormPlaceholderImages[formState.images.length % hallFormPlaceholderImages.length];
    ref.read(hallFormControllerProvider(_formKey).notifier).addImage(next);
  }

  Future<void> pickVirtualTourImage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (context) =>
          const _GalleryPickerSheet(images: hallFormPlaceholderImages),
    );

    if (selected != null) {
      ref
          .read(hallFormControllerProvider(_formKey).notifier)
          .setVirtualTourImage(selected);
    }
  }

  void previewVirtualTour() {
    final panoramaImage =
        ref.read(hallFormControllerProvider(_formKey)).virtualTourImage;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VirtualTourScreen(
          hallName: nameController.text.trim().isEmpty
              ? "Your Hall"
              : nameController.text.trim(),
          tourUrl: panoramaImage!,
        ),
      ),
    );
  }

  Future<void> saveHall() async {
    final formState = ref.read(hallFormControllerProvider(_formKey));

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hall name is required")));
      return;
    }

    if (formState.selectedTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one time slot")),
      );
      return;
    }

    final capacity = int.tryParse(capacityController.text.trim());
    final pricePerDay = double.tryParse(priceController.text.trim());

    if (!widget.isEditMode) {
      // Only the create flow is wired to a real endpoint (no PUT was given
      // yet for edits), so these need to be genuinely valid numbers here.
      if (capacity == null || capacity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid guest capacity (a number)"),
          ),
        );
        return;
      }

      if (pricePerDay == null || pricePerDay <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid base hall price (a number)"),
          ),
        );
        return;
      }
    }

    final extraServices = List.generate(formState.extraServiceNames.length, (
      index,
    ) {
      final name = formState.extraServiceNames[index];
      return {
        'name': name,
        'price': _priceControllerFor(name).text.trim().isEmpty
            ? '0'
            : _priceControllerFor(name).text.trim(),
        'enabled': formState.extraServiceEnabled[index],
      };
    });

    final hallData = {
      'imagePath': formState.images.isNotEmpty
          ? formState.images.first
          : hallFormPlaceholderImages.first,
      'images': formState.images,
      'virtualTourImage': formState.virtualTourImage,
      'hallName': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'city': formState.selectedCity,
      'address': addressController.text.trim(),
      'capacity': capacityController.text.trim(),
      'price': priceController.text.trim(),
      'pricePerPerson': pricePerPersonController.text.trim(),
      'parkingSpaces': '${formState.parkingSpaces}',
      'bridalRooms': '${formState.bridalRooms}',
      'washrooms': '${formState.washrooms}',
      'hasAC': formState.hasAC,
      'hasGenerator': formState.hasGenerator,
      'hasCatering': formState.hasCatering,
      'isAvailable': _hall['isAvailable'] ?? true,
      'status': _isResubmission
          ? HallStatus.pending
          : (_hall['status'] ?? HallStatus.pending),
      'rejectionReason': _isResubmission ? null : _hall['rejectionReason'],
      'foodPackages': formState.foodPackages,
      'extraServices': extraServices,
      'availableDays': formState.availableDays,
      'timeSlots': formState.selectedTimeSlots,
      'advancePaymentType': formState.advancePaymentType,
      'advancePercentage': formState.advancePercentage,
      'ownerName': ownerNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'whatsapp': whatsappController.text.trim(),
      'email': emailController.text.trim(),
    };

    if (!widget.isEditMode) {
      // Real backend call — only name/description/address/city/capacity/
      // pricePerDay exist on this endpoint. Everything else above (food
      // packages, images, parking, AC, advance %, ...) has no matching API
      // yet, so it stays local-only on this dummy record for now.
      final hall = await ref
          .read(createHallControllerProvider.notifier)
          .submit(
            CreateHallRequest(
              name: nameController.text.trim(),
              description: descriptionController.text.trim(),
              address: addressController.text.trim(),
              city: formState.selectedCity,
              capacity: capacity!,
              pricePerDay: pricePerDay!,
            ),
          );

      if (!mounted) return;

      if (hall == null) {
        final message = ref.read(createHallControllerProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Could not create hall")),
        );
        return;
      }

      hallData['hallId'] = hall.id;
      hallData['hallName'] = hall.name;
      hallData['description'] = hall.description;
      hallData['city'] = hall.city;
      hallData['address'] = hall.address;
      hallData['capacity'] = '${hall.capacity}';
      hallData['price'] = hall.pricePerDay.toStringAsFixed(0);
      hallData['isAvailable'] = hall.isActive;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isResubmission
              ? "Hall resubmitted for review!"
              : widget.isEditMode
              ? "Hall updated!"
              : "Hall created!",
        ),
      ),
    );

    Navigator.pop(context, hallData);
  }

  @override
  Widget build(BuildContext context) {
    const cities = ['Lahore', 'Karachi', 'Islamabad', 'Rawalpindi'];
    final formState = ref.watch(hallFormControllerProvider(_formKey));
    final formNotifier = ref.read(hallFormControllerProvider(_formKey).notifier);
    final isSaving = ref.watch(
      createHallControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditMode ? "Edit Hall" : "Add New Hall"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isResubmission) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                margin: const EdgeInsets.only(bottom: AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        SizedBox(width: AppSizes.sm),
                        Text(
                          "Rejected by Admin",
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      _hall['rejectionReason'] ?? 'No reason was provided.',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    const Text(
                      "Fix the issue above and resubmit for review.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SectionCard(
              icon: Icons.info_outline,
              title: "Basic Information",
              child: Column(
                children: [
                  LabeledTextField(
                    controller: nameController,
                    label: "Hall Name",
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: descriptionController,
                    label: "Hall Description",
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSizes.md),
                  DropdownButtonFormField<String>(
                    initialValue: cities.contains(formState.selectedCity)
                        ? formState.selectedCity
                        : cities.first,
                    decoration: const InputDecoration(
                      labelText: "City",
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: cities
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) formNotifier.setCity(value);
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: addressController,
                    label: "Full Address",
                    icon: Icons.map_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSizes.md),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Map picker isn't wired up in this UI-only build.",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_pin, color: AppColors.primary),
                          SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              "Pick location on Google Maps",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SectionCard(
              icon: Icons.meeting_room_outlined,
              title: "Hall Details",
              child: Column(
                children: [
                  LabeledTextField(
                    controller: capacityController,
                    label: "Max Guest Capacity",
                    icon: Icons.groups_outlined,
                    hint: "e.g. 500",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: priceController,
                    label: "Base Hall Price (PKR)",
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: pricePerPersonController,
                    label: "Booking Price Per Person (optional)",
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSizes.md),
                  StepperField(
                    icon: Icons.local_parking_outlined,
                    label: "Parking Spaces",
                    value: formState.parkingSpaces,
                    onIncrement: () =>
                        formNotifier.setParkingSpaces(formState.parkingSpaces + 1),
                    onDecrement: () =>
                        formNotifier.setParkingSpaces(formState.parkingSpaces - 1),
                  ),
                  StepperField(
                    icon: Icons.room_preferences_outlined,
                    label: "Bridal Rooms",
                    value: formState.bridalRooms,
                    onIncrement: () =>
                        formNotifier.setBridalRooms(formState.bridalRooms + 1),
                    onDecrement: () =>
                        formNotifier.setBridalRooms(formState.bridalRooms - 1),
                  ),
                  StepperField(
                    icon: Icons.wc_outlined,
                    label: "Washrooms",
                    value: formState.washrooms,
                    onIncrement: () =>
                        formNotifier.setWashrooms(formState.washrooms + 1),
                    onDecrement: () =>
                        formNotifier.setWashrooms(formState.washrooms - 1),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ToggleRow(
                    icon: Icons.ac_unit,
                    label: "Air Conditioning",
                    value: formState.hasAC,
                    onChanged: formNotifier.setHasAC,
                  ),
                  ToggleRow(
                    icon: Icons.bolt,
                    label: "Generator Backup",
                    value: formState.hasGenerator,
                    onChanged: formNotifier.setHasGenerator,
                  ),
                  ToggleRow(
                    icon: Icons.restaurant,
                    label: "Catering Available",
                    value: formState.hasCatering,
                    onChanged: formNotifier.setHasCatering,
                  ),
                ],
              ),
            ),

            SectionCard(
              icon: Icons.restaurant_menu,
              title: "Food Packages",
              subtitle: "Define the packages guests can choose from",
              child: Column(
                children: [
                  ...formState.foodPackages.asMap().entries.map((entry) {
                    return FoodPackageCard(
                      package: entry.value,
                      onDelete: () => formNotifier.removeFoodPackageAt(entry.key),
                    );
                  }),
                  const SizedBox(height: AppSizes.sm),
                  OutlinedButton.icon(
                    onPressed: addFoodPackage,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Food Package"),
                  ),
                ],
              ),
            ),

            SectionCard(
              icon: Icons.room_service_outlined,
              title: "Extra Services",
              subtitle: "Optional add-ons with their own pricing",
              child: Column(
                children: [
                  ...List.generate(formState.extraServiceNames.length, (index) {
                    final name = formState.extraServiceNames[index];
                    return ExtraServiceRow(
                      name: name,
                      priceController: _priceControllerFor(name),
                      enabled: formState.extraServiceEnabled[index],
                      onToggle: (value) =>
                          formNotifier.toggleExtraServiceEnabled(index, value),
                      onDelete: () {
                        _extraServicePriceControllers.remove(name)?.dispose();
                        formNotifier.removeExtraServiceAt(index);
                      },
                    );
                  }),
                  const SizedBox(height: AppSizes.sm),
                  OutlinedButton.icon(
                    onPressed: addCustomService,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Custom Service"),
                  ),
                ],
              ),
            ),

            SectionCard(
              icon: Icons.photo_library_outlined,
              title: "Hall Images",
              subtitle: "Add up to 6 photos to showcase your hall",
              child: ImagePickerGrid(
                images: formState.images,
                onAdd: addImage,
                onRemove: (index) => formNotifier.removeImageAt(index),
              ),
            ),

            SectionCard(
              icon: Icons.threesixty,
              title: "360° Virtual Tour",
              subtitle:
                  "Upload a 360° panorama image to help clients explore your hall virtually.",
              child: _VirtualTourSection(
                virtualTourImage: formState.virtualTourImage,
                onUpload: pickVirtualTourImage,
                onReplace: pickVirtualTourImage,
                onRemove: formNotifier.removeVirtualTourImage,
                onPreview: previewVirtualTour,
              ),
            ),

            SectionCard(
              icon: Icons.event_available_outlined,
              title: "Availability",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Days",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  DaySelector(
                    selectedDays: formState.availableDays,
                    onToggle: formNotifier.toggleAvailableDay,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    "Available Time Slot",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Select the slot(s) your hall is available for",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  for (final slot in hallTimeSlots) ...[
                    _SlotTile(
                      label: slot['label']!,
                      time: slot['time']!,
                      isSelected: formState.selectedTimeSlots.contains(
                        slot['id'],
                      ),
                      onTap: () => formNotifier.toggleTimeSlot(slot['id']!),
                    ),
                    if (slot != hallTimeSlots.last)
                      const SizedBox(height: AppSizes.sm),
                  ],
                  const SizedBox(height: AppSizes.md),
                  const AvailabilityCalendarPreview(),
                ],
              ),
            ),

            SectionCard(
              icon: Icons.payments_outlined,
              title: "Booking Payment Settings",
              subtitle: "Set how much advance a client must pay to confirm",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Advance Payment Type",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentTypeTile(
                          label: "Percentage (%)",
                          isSelected: formState.advancePaymentType == 'percentage',
                          onTap: () =>
                              formNotifier.setAdvancePaymentType('percentage'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      const Expanded(
                        child: _PaymentTypeTile(
                          label: "Fixed Amount",
                          subLabel: "Coming Soon",
                          isSelected: false,
                          onTap: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    "Advance Payment Required (%)",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  StepperField(
                    icon: Icons.percent,
                    label: "${formState.advancePercentage}% of total booking amount",
                    value: formState.advancePercentage,
                    onIncrement: () => formNotifier.setAdvancePercentage(
                      formState.advancePercentage + 5,
                    ),
                    onDecrement: () => formNotifier.setAdvancePercentage(
                      formState.advancePercentage - 5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    "A client will pay ${formState.advancePercentage}% of the final booking "
                    "amount to confirm this hall; the remaining balance is "
                    "settled directly with you.",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SectionCard(
              icon: Icons.contact_phone_outlined,
              title: "Contact Information",
              child: Column(
                children: [
                  LabeledTextField(
                    controller: ownerNameController,
                    label: "Owner Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: whatsappController,
                    label: "WhatsApp Number",
                    icon: Icons.chat_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.md),
                  LabeledTextField(
                    controller: emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.sm),
            GradientButton(
              label: isSaving
                  ? "Saving..."
                  : (_isResubmission ? "Resubmit for Approval" : "Save Hall"),
              icon: Icons.check_circle_outline,
              onPressed: isSaving ? null : saveHall,
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _PaymentTypeTile extends StatelessWidget {
  final String label;
  final String? subLabel;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PaymentTypeTile({
    required this.label,
    this.subLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDisabled
                          ? AppColors.textSecondary
                          : (isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                subLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final String label;
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotTile({
    required this.label,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VirtualTourSection extends StatelessWidget {
  final String? virtualTourImage;
  final VoidCallback onUpload;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onPreview;

  const _VirtualTourSection({
    required this.virtualTourImage,
    required this.onUpload,
    required this.onReplace,
    required this.onRemove,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final image = virtualTourImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image == null)
          GestureDetector(
            onTap: onUpload,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.threesixty, size: 32, color: AppColors.primary),
                  SizedBox(height: 6),
                  Text(
                    "Upload 360° Panorama Image",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Stack(
              children: [
                Image.asset(
                  image,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.threesixty, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "360° Preview",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.play_circle_outline, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Preview"),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReplace,
                  icon: const Icon(Icons.sync, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Replace"),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSizes.sm),
        const Text(
          "Use a wide panorama or 360° image for best results.",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GalleryPickerSheet extends StatelessWidget {
  final List<String> images;

  const _GalleryPickerSheet({required this.images});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                const Text(
                  "Choose from Gallery",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSizes.sm,
                crossAxisSpacing: AppSizes.sm,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, images[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Image.asset(images[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }
}
