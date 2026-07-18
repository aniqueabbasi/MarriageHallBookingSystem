import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marriage_hall_app/constants/lists.dart';
import 'package:marriage_hall_app/models/halls/create_extra_service_request.dart';
import 'package:marriage_hall_app/models/halls/create_food_package_request.dart';

/// Key identifying a single [AddEditHallScreen] instance's form state:
/// a unique per-instance token paired with the (identity-stable) initial
/// hall map that screen instance was opened with.
typedef HallFormKey = (String formId, Map<String, dynamic>? initialHall);

class HallFormState {
  final String selectedCity;
  final int parkingSpaces;
  final int bridalRooms;
  final int washrooms;
  final bool hasAC;
  final bool hasGenerator;
  final bool hasCatering;
  final String advancePaymentType;
  final int advancePercentage;
  final List<String> availableDays;
  final List<String> selectedTimeSlots;
  final bool isActive;

  /// Create-mode-only staging: nothing is uploaded/submitted until the
  /// hall itself is saved, since food packages/extra services/images can
  /// now only be set at creation via the same multipart POST as the hall.
  final List<XFile> pickedImages;
  final List<CreateFoodPackageRequest> stagedFoodPackages;
  final List<CreateExtraServiceRequest> stagedExtraServices;

  const HallFormState({
    required this.selectedCity,
    required this.parkingSpaces,
    required this.bridalRooms,
    required this.washrooms,
    required this.hasAC,
    required this.hasGenerator,
    required this.hasCatering,
    required this.advancePaymentType,
    required this.advancePercentage,
    required this.availableDays,
    required this.selectedTimeSlots,
    this.isActive = true,
    this.pickedImages = const [],
    this.stagedFoodPackages = const [],
    this.stagedExtraServices = const [],
  });

  factory HallFormState.fromHall(Map<String, dynamic> hall) {
    return HallFormState(
      selectedCity: hall['city'] ?? 'Lahore',
      parkingSpaces: int.tryParse('${hall['parkingSpaces']}') ?? 50,
      bridalRooms: int.tryParse('${hall['bridalRooms']}') ?? 1,
      washrooms: int.tryParse('${hall['washrooms']}') ?? 4,
      hasAC: hall['hasAC'] ?? true,
      hasGenerator: hall['hasGenerator'] ?? true,
      hasCatering: hall['hasCatering'] ?? true,
      advancePaymentType: hall['advancePaymentType'] ?? 'percentage',
      advancePercentage:
          int.tryParse('${hall['advancePercentage'] ?? 20}') ?? 20,
      availableDays: List<String>.from(
        (hall['availableDays'] as List?) ?? const ['Sat', 'Sun'],
      ),
      selectedTimeSlots: List<String>.from(
        (hall['timeSlots'] as List?) ?? const ['day'],
      ),
      isActive: hall['isActive'] ?? true,
    );
  }

  HallFormState copyWith({
    String? selectedCity,
    int? parkingSpaces,
    int? bridalRooms,
    int? washrooms,
    bool? hasAC,
    bool? hasGenerator,
    bool? hasCatering,
    String? advancePaymentType,
    int? advancePercentage,
    List<String>? availableDays,
    List<String>? selectedTimeSlots,
    bool? isActive,
    List<XFile>? pickedImages,
    List<CreateFoodPackageRequest>? stagedFoodPackages,
    List<CreateExtraServiceRequest>? stagedExtraServices,
  }) {
    return HallFormState(
      selectedCity: selectedCity ?? this.selectedCity,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      bridalRooms: bridalRooms ?? this.bridalRooms,
      washrooms: washrooms ?? this.washrooms,
      hasAC: hasAC ?? this.hasAC,
      hasGenerator: hasGenerator ?? this.hasGenerator,
      hasCatering: hasCatering ?? this.hasCatering,
      advancePaymentType: advancePaymentType ?? this.advancePaymentType,
      advancePercentage: advancePercentage ?? this.advancePercentage,
      availableDays: availableDays ?? this.availableDays,
      selectedTimeSlots: selectedTimeSlots ?? this.selectedTimeSlots,
      isActive: isActive ?? this.isActive,
      pickedImages: pickedImages ?? this.pickedImages,
      stagedFoodPackages: stagedFoodPackages ?? this.stagedFoodPackages,
      stagedExtraServices: stagedExtraServices ?? this.stagedExtraServices,
    );
  }
}

class HallFormController extends Notifier<HallFormState> {
  final HallFormKey arg;

  HallFormController(this.arg);

  @override
  HallFormState build() {
    return HallFormState.fromHall(arg.$2 ?? const {});
  }

  void setCity(String city) => state = state.copyWith(selectedCity: city);

  void setParkingSpaces(int value) {
    if (value >= 0) state = state.copyWith(parkingSpaces: value);
  }

  void setBridalRooms(int value) {
    if (value >= 0) state = state.copyWith(bridalRooms: value);
  }

  void setWashrooms(int value) {
    if (value >= 0) state = state.copyWith(washrooms: value);
  }

  void setHasAC(bool value) => state = state.copyWith(hasAC: value);

  void setHasGenerator(bool value) =>
      state = state.copyWith(hasGenerator: value);

  void setHasCatering(bool value) =>
      state = state.copyWith(hasCatering: value);

  void setAdvancePaymentType(String type) =>
      state = state.copyWith(advancePaymentType: type);

  void setAdvancePercentage(int value) {
    if (value >= 5 && value <= 100) {
      state = state.copyWith(advancePercentage: value);
    }
  }

  void addPickedImages(List<XFile> images) {
    final room = hallFormMaxImages - state.pickedImages.length;
    if (room <= 0) return;
    state = state.copyWith(
      pickedImages: [...state.pickedImages, ...images.take(room)],
    );
  }

  void removePickedImageAt(int index) {
    final updated = [...state.pickedImages]..removeAt(index);
    state = state.copyWith(pickedImages: updated);
  }

  void addStagedFoodPackage(CreateFoodPackageRequest request) {
    state = state.copyWith(
      stagedFoodPackages: [...state.stagedFoodPackages, request],
    );
  }

  void removeStagedFoodPackageAt(int index) {
    final updated = [...state.stagedFoodPackages]..removeAt(index);
    state = state.copyWith(stagedFoodPackages: updated);
  }

  void addStagedExtraService(CreateExtraServiceRequest request) {
    state = state.copyWith(
      stagedExtraServices: [...state.stagedExtraServices, request],
    );
  }

  void removeStagedExtraServiceAt(int index) {
    final updated = [...state.stagedExtraServices]..removeAt(index);
    state = state.copyWith(stagedExtraServices: updated);
  }

  void toggleAvailableDay(String day) {
    final updated = [...state.availableDays];
    if (!updated.remove(day)) updated.add(day);
    state = state.copyWith(availableDays: updated);
  }

  void toggleTimeSlot(String slotId) {
    final updated = [...state.selectedTimeSlots];
    if (!updated.remove(slotId)) updated.add(slotId);
    state = state.copyWith(selectedTimeSlots: updated);
  }

  void setIsActive(bool value) => state = state.copyWith(isActive: value);
}

final hallFormControllerProvider = NotifierProvider.autoDispose
    .family<HallFormController, HallFormState, HallFormKey>(
      HallFormController.new,
    );
