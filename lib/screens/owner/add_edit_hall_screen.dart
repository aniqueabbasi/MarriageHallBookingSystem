import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/halls/create_hall_controller.dart';
import 'package:marriage_hall_app/controllers/halls/extra_service_controller.dart';
import 'package:marriage_hall_app/controllers/halls/food_package_controller.dart';
import 'package:marriage_hall_app/controllers/halls/hall_detail_controller.dart';
import 'package:marriage_hall_app/controllers/halls/hall_form_controller.dart';
import 'package:marriage_hall_app/controllers/halls/my_halls_controller.dart';
import 'package:marriage_hall_app/controllers/halls/update_hall_controller.dart';
import 'package:marriage_hall_app/controllers/halls/virtual_tour_controller.dart';
import 'package:marriage_hall_app/models/halls/create_extra_service_request.dart';
import 'package:marriage_hall_app/models/halls/create_food_package_request.dart';
import 'package:marriage_hall_app/models/halls/create_hall_request.dart';
import 'package:marriage_hall_app/models/halls/extra_service.dart';
import 'package:marriage_hall_app/models/halls/food_package.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';
import 'package:marriage_hall_app/models/halls/update_hall_request.dart';
import 'package:marriage_hall_app/models/halls/virtual_tour_info.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/add_extra_service_dialog.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/add_food_package_dialog.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/add_virtual_tour_dialog.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/availability_calendar_preview.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/day_selector.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/extra_service_row.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/food_package_card.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/image_picker_grid.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/labeled_text_field.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/section_card.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/stepper_field.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/toggle_row.dart';
import 'package:marriage_hall_app/widgets/owner/hall_form/virtual_tour_row.dart';

const List<Map<String, String>> hallTimeSlots = [
  {'id': 'day', 'label': 'Day Slot', 'time': '12:00 PM - 5:00 PM'},
  {'id': 'evening', 'label': 'Evening Slot', 'time': '6:00 PM - 10:00 PM'},
];

/// Entry point. In edit mode this first loads the real hall via
/// [hallDetailProvider] (a [HallSummary] from My Halls isn't enough — no
/// description/address) and only renders the form once that resolves.
class AddEditHallScreen extends ConsumerWidget {
  final int? hallId;

  const AddEditHallScreen({super.key, this.hallId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = hallId;
    if (id == null) {
      return const _HallFormScreen(hallId: null, hall: null);
    }

    final hallAsync = ref.watch(hallDetailProvider(id));
    return hallAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text("Edit Hall")),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text("Edit Hall")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text("Could not load this hall: ${error.toString()}"),
          ),
        ),
      ),
      data: (hall) => _HallFormScreen(hallId: id, hall: hall),
    );
  }
}

class _HallFormScreen extends ConsumerStatefulWidget {
  final int? hallId;
  final Hall? hall;

  const _HallFormScreen({required this.hallId, required this.hall});

  bool get isEditMode => hallId != null;

  @override
  ConsumerState<_HallFormScreen> createState() => _HallFormScreenState();
}

class _HallFormScreenState extends ConsumerState<_HallFormScreen> {
  late final HallFormKey _formKey = (
    UniqueKey().toString(),
    widget.hall == null
        ? null
        : {'city': widget.hall!.city, 'isActive': widget.hall!.isActive},
  );

  // Basic Information
  late final nameController = TextEditingController(
    text: widget.hall?.name ?? '',
  );
  late final descriptionController = TextEditingController(
    text: widget.hall?.description ?? '',
  );
  late final addressController = TextEditingController(
    text: widget.hall?.address ?? '',
  );

  // Hall Details
  late final capacityController = TextEditingController(
    text: widget.hall == null ? '' : '${widget.hall!.capacity}',
  );
  late final priceController = TextEditingController(
    text: widget.hall == null
        ? ''
        : widget.hall!.pricePerDay.toStringAsFixed(0),
  );
  final pricePerPersonController = TextEditingController();

  // Contact Information — no backing field on the real Hall model yet.
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final emailController = TextEditingController();

  int? _deletingFoodPackageId;
  int? _deletingExtraServiceId;
  int? _deletingVirtualTourId;

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
    super.dispose();
  }

  Future<void> addFoodPackage() async {
    final request = await showDialog<CreateFoodPackageRequest>(
      context: context,
      builder: (context) => const AddFoodPackageDialog(),
    );
    if (request == null) return;

    if (!widget.isEditMode) {
      ref
          .read(hallFormControllerProvider(_formKey).notifier)
          .addStagedFoodPackage(request);
      return;
    }

    final hallId = widget.hallId!;
    final current = widget.hall!;
    final hall = await ref
        .read(updateHallControllerProvider(hallId).notifier)
        .submit(
          hallId,
          UpdateHallRequest(
            name: current.name,
            description: current.description,
            address: current.address,
            city: current.city,
            capacity: current.capacity,
            pricePerDay: current.pricePerDay,
            isActive: current.isActive,
            foodPackages: [
              ...current.foodPackages.map((p) => p.toCreateRequest()),
              request,
            ],
            extraServices: current.extraServices
                .map((s) => s.toCreateRequest())
                .toList(),
          ),
        );

    if (!mounted) return;

    if (hall == null) {
      final message = ref
          .read(updateHallControllerProvider(hallId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not add food package")),
      );
      return;
    }

    ref.invalidate(hallDetailProvider(hallId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Food package added.")));
  }

  Future<void> confirmDeleteFoodPackage(FoodPackage package) async {
    final hallId = widget.hallId;
    if (hallId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Food Package"),
        content: Text(
          'Remove "${package.name}"? This can\'t be undone from here. '
          "Bookings that already picked this package keep it — it just "
          "won't be offered on new bookings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Remove",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _deletingFoodPackageId = package.id);
    final success = await ref
        .read(foodPackageControllerProvider(hallId).notifier)
        .deletePackage(hallId, package.id);

    if (!mounted) return;
    setState(() => _deletingFoodPackageId = null);

    if (success) {
      ref.invalidate(hallDetailProvider(hallId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food package removed.")),
      );
    } else {
      final message = ref
          .read(foodPackageControllerProvider(hallId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not remove food package")),
      );
    }
  }

  Future<void> addExtraService() async {
    final request = await showDialog<CreateExtraServiceRequest>(
      context: context,
      builder: (context) => const AddExtraServiceDialog(),
    );
    if (request == null) return;

    if (!widget.isEditMode) {
      ref
          .read(hallFormControllerProvider(_formKey).notifier)
          .addStagedExtraService(request);
      return;
    }

    final hallId = widget.hallId!;
    final current = widget.hall!;
    final hall = await ref
        .read(updateHallControllerProvider(hallId).notifier)
        .submit(
          hallId,
          UpdateHallRequest(
            name: current.name,
            description: current.description,
            address: current.address,
            city: current.city,
            capacity: current.capacity,
            pricePerDay: current.pricePerDay,
            isActive: current.isActive,
            foodPackages: current.foodPackages
                .map((p) => p.toCreateRequest())
                .toList(),
            extraServices: [
              ...current.extraServices.map((s) => s.toCreateRequest()),
              request,
            ],
          ),
        );

    if (!mounted) return;

    if (hall == null) {
      final message = ref
          .read(updateHallControllerProvider(hallId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not add service")),
      );
      return;
    }

    ref.invalidate(hallDetailProvider(hallId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Service added.")));
  }

  Future<void> confirmDeleteExtraService(ExtraService service) async {
    final hallId = widget.hallId;
    if (hallId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Service"),
        content: Text(
          'Remove "${service.name}"? This can\'t be undone from here. '
          "Bookings that already picked this service keep it — it just "
          "won't be offered on new bookings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Remove",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _deletingExtraServiceId = service.id);
    final success = await ref
        .read(extraServiceControllerProvider(hallId).notifier)
        .deleteService(hallId, service.id);

    if (!mounted) return;
    setState(() => _deletingExtraServiceId = null);

    if (success) {
      ref.invalidate(hallDetailProvider(hallId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service removed.")));
    } else {
      final message = ref
          .read(extraServiceControllerProvider(hallId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not remove service")),
      );
    }
  }

  /// Create mode only — picked photos are staged locally and uploaded
  /// together when the hall itself is submitted.
  Future<void> pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) return;
    if (!mounted) return;
    ref
        .read(hallFormControllerProvider(_formKey).notifier)
        .addPickedImages(picked);
  }

  /// Edit mode only — images can only be added (never removed) via a
  /// multipart update; there's no image-delete endpoint.
  Future<void> addPhotos() async {
    final hallId = widget.hallId;
    if (hallId == null) return;

    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) return;
    if (!mounted) return;

    final current = widget.hall!;
    final hall = await ref
        .read(updateHallControllerProvider(hallId).notifier)
        .submit(
          hallId,
          UpdateHallRequest(
            name: current.name,
            description: current.description,
            address: current.address,
            city: current.city,
            capacity: current.capacity,
            pricePerDay: current.pricePerDay,
            isActive: current.isActive,
            foodPackages: current.foodPackages
                .map((p) => p.toCreateRequest())
                .toList(),
            extraServices: current.extraServices
                .map((s) => s.toCreateRequest())
                .toList(),
            newImages: picked,
          ),
        );

    if (!mounted) return;

    if (hall == null) {
      final message = ref
          .read(updateHallControllerProvider(hallId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not add photos")),
      );
      return;
    }

    ref.invalidate(hallDetailProvider(hallId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Photos added.")));
  }

  Future<void> addVirtualTour() async {
    final hallId = widget.hallId;
    if (hallId == null) return;

    final tour = await showDialog<VirtualTourInfo>(
      context: context,
      builder: (context) => AddVirtualTourDialog(hallId: hallId),
    );

    if (tour != null) {
      ref.invalidate(hallDetailProvider(hallId));
    }
  }

  Future<void> confirmDeleteVirtualTour(VirtualTourInfo tour) async {
    final hallId = widget.hallId;
    if (hallId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Virtual Tour"),
        content: Text(
          'Remove "${tour.title}"? This can\'t be undone from here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Remove",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _deletingVirtualTourId = tour.id);
    final success = await ref
        .read(virtualTourControllerProvider(hallId).notifier)
        .deleteTour(hallId, tour.id);

    if (!mounted) return;
    setState(() => _deletingVirtualTourId = null);

    if (success) {
      ref.invalidate(hallDetailProvider(hallId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Virtual tour removed.")));
    } else {
      final message = ref
          .read(virtualTourControllerProvider(hallId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not remove virtual tour")),
      );
    }
  }

  Future<void> saveHall() async {
    final formState = ref.read(hallFormControllerProvider(_formKey));

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hall name is required")));
      return;
    }

    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address is required")),
      );
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

    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid guest capacity (a number)")),
      );
      return;
    }

    if (pricePerDay == null || pricePerDay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid base hall price (a number)")),
      );
      return;
    }

    if (!widget.isEditMode && formState.pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one photo of your hall")),
      );
      return;
    }

    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final address = addressController.text.trim();
    final city = formState.selectedCity;

    if (widget.isEditMode) {
      final hallId = widget.hallId!;
      final hall = await ref
          .read(updateHallControllerProvider(hallId).notifier)
          .submit(
            hallId,
            UpdateHallRequest(
              name: name,
              description: description,
              address: address,
              city: city,
              capacity: capacity,
              pricePerDay: pricePerDay,
              isActive: formState.isActive,
              foodPackages: widget.hall!.foodPackages
                  .map((p) => p.toCreateRequest())
                  .toList(),
              extraServices: widget.hall!.extraServices
                  .map((s) => s.toCreateRequest())
                  .toList(),
            ),
          );

      if (!mounted) return;

      if (hall == null) {
        final message = ref.read(updateHallControllerProvider(hallId)).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Could not update hall")),
        );
        return;
      }

      ref.invalidate(myHallsProvider);
      ref.invalidate(hallDetailProvider(hallId));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hall updated!")));
      Navigator.pop(context, true);
      return;
    }

    final hall = await ref
        .read(createHallControllerProvider.notifier)
        .submit(
          CreateHallRequest(
            name: name,
            description: description,
            address: address,
            city: city,
            capacity: capacity,
            pricePerDay: pricePerDay,
            images: formState.pickedImages,
            foodPackages: formState.stagedFoodPackages,
            extraServices: formState.stagedExtraServices,
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Hall created!")));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const cities = ['Lahore', 'Karachi', 'Islamabad', 'Rawalpindi'];
    final formState = ref.watch(hallFormControllerProvider(_formKey));
    final formNotifier = ref.read(hallFormControllerProvider(_formKey).notifier);
    final isSaving = widget.isEditMode
        ? ref.watch(
            updateHallControllerProvider(widget.hallId!).select((s) => s.isLoading),
          )
        : ref.watch(createHallControllerProvider.select((s) => s.isLoading));
    // Watched here (not just read from inside the dialogs/delete handlers)
    // so these autoDispose providers stay alive for the duration of their
    // async add/delete calls — see the update-hall autoDispose teardown fix.
    final isFoodPackageBusy = widget.isEditMode
        ? ref.watch(
            foodPackageControllerProvider(widget.hallId!).select((s) => s.isLoading),
          )
        : false;
    final isExtraServiceBusy = widget.isEditMode
        ? ref.watch(
            extraServiceControllerProvider(widget.hallId!).select((s) => s.isLoading),
          )
        : false;
    final isVirtualTourBusy = widget.isEditMode
        ? ref.watch(
            virtualTourControllerProvider(widget.hallId!).select((s) => s.isLoading),
          )
        : false;

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
                  if (widget.isEditMode) ...[
                    const SizedBox(height: AppSizes.sm),
                    ToggleRow(
                      icon: Icons.visibility_outlined,
                      label: "Active (visible to clients)",
                      value: formState.isActive,
                      onChanged: formNotifier.setIsActive,
                    ),
                  ],
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
              child: widget.isEditMode
                  ? Column(
                      children: [
                        ...(widget.hall?.foodPackages ?? const []).map((
                          package,
                        ) {
                          return FoodPackageCard(
                            package: package,
                            isDeleting: _deletingFoodPackageId == package.id,
                            onDelete: isFoodPackageBusy
                                ? null
                                : () => confirmDeleteFoodPackage(package),
                          );
                        }),
                        const SizedBox(height: AppSizes.sm),
                        OutlinedButton.icon(
                          onPressed: isFoodPackageBusy ? null : addFoodPackage,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Food Package"),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ...formState.stagedFoodPackages.asMap().entries.map((
                          entry,
                        ) {
                          final staged = entry.value;
                          return FoodPackageCard(
                            package: FoodPackage(
                              id: 0,
                              name: staged.name,
                              description: staged.description,
                              pricePerHead: staged.pricePerHead,
                            ),
                            isDeleting: false,
                            onDelete: () => formNotifier
                                .removeStagedFoodPackageAt(entry.key),
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
              child: widget.isEditMode
                  ? Column(
                      children: [
                        ...(widget.hall?.extraServices ?? const []).map((
                          service,
                        ) {
                          return ExtraServiceRow(
                            service: service,
                            isDeleting: _deletingExtraServiceId == service.id,
                            onDelete: isExtraServiceBusy
                                ? null
                                : () => confirmDeleteExtraService(service),
                          );
                        }),
                        const SizedBox(height: AppSizes.sm),
                        OutlinedButton.icon(
                          onPressed: isExtraServiceBusy
                              ? null
                              : addExtraService,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Custom Service"),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ...formState.stagedExtraServices.asMap().entries.map((
                          entry,
                        ) {
                          final staged = entry.value;
                          return ExtraServiceRow(
                            service: ExtraService(
                              id: 0,
                              name: staged.name,
                              description: staged.description,
                              price: staged.price,
                            ),
                            isDeleting: false,
                            onDelete: () => formNotifier
                                .removeStagedExtraServiceAt(entry.key),
                          );
                        }),
                        const SizedBox(height: AppSizes.sm),
                        OutlinedButton.icon(
                          onPressed: addExtraService,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Custom Service"),
                        ),
                      ],
                    ),
            ),

            SectionCard(
              icon: Icons.photo_library_outlined,
              title: "Hall Images",
              subtitle: widget.isEditMode
                  ? "Add more photos to showcase your hall"
                  : "Add up to 6 photos to showcase your hall — at least one is required",
              child: widget.isEditMode
                  ? ExistingImagesGrid(
                      images: widget.hall!.images,
                      onAddPhotos: addPhotos,
                      isUploading: isSaving,
                    )
                  : PickedImagesGrid(
                      images: formState.pickedImages,
                      onAdd: pickImages,
                      onRemove: (index) =>
                          formNotifier.removePickedImageAt(index),
                    ),
            ),

            SectionCard(
              icon: Icons.threesixty,
              title: "360° Virtual Tour",
              subtitle:
                  "Add 360° tour links to help clients explore your hall virtually.",
              child: widget.isEditMode
                  ? Column(
                      children: [
                        ...(widget.hall?.virtualTours ?? const []).map((
                          tour,
                        ) {
                          return VirtualTourRow(
                            tour: tour,
                            isDeleting: _deletingVirtualTourId == tour.id,
                            onDelete: isVirtualTourBusy
                                ? null
                                : () => confirmDeleteVirtualTour(tour),
                          );
                        }),
                        const SizedBox(height: AppSizes.sm),
                        OutlinedButton.icon(
                          onPressed: isVirtualTourBusy
                              ? null
                              : addVirtualTour,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Virtual Tour"),
                        ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                      child: Text(
                        "Save this hall first, then come back here to add "
                        "virtual tours.",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
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
                  : (widget.isEditMode ? "Update Hall" : "Save Hall"),
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

