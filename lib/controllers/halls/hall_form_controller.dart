import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/constants/lists.dart';

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
  final List<Map<String, dynamic>> foodPackages;
  final List<String> extraServiceNames;
  final List<bool> extraServiceEnabled;
  final List<String> images;
  final String? virtualTourImage;
  final List<String> availableDays;
  final List<String> selectedTimeSlots;

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
    required this.foodPackages,
    required this.extraServiceNames,
    required this.extraServiceEnabled,
    required this.images,
    required this.virtualTourImage,
    required this.availableDays,
    required this.selectedTimeSlots,
  });

  factory HallFormState.fromHall(Map<String, dynamic> hall) {
    final existingServices = List<Map<String, dynamic>>.from(
      (hall['extraServices'] as List?) ?? const [],
    );
    final names = [...defaultExtraServiceNames];
    for (final service in existingServices) {
      if (!names.contains(service['name'])) {
        names.add(service['name']);
      }
    }
    final enabled = names.map((name) {
      final match = existingServices.where((e) => e['name'] == name);
      if (match.isEmpty) return false;
      return match.first['enabled'] == true;
    }).toList();

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
      foodPackages: List<Map<String, dynamic>>.from(
        (hall['foodPackages'] as List?) ?? const [],
      ),
      extraServiceNames: names,
      extraServiceEnabled: enabled,
      images: List<String>.from(
        (hall['images'] as List?) ??
            (hall['imagePath'] != null ? [hall['imagePath']] : const []),
      ),
      virtualTourImage: hall['virtualTourImage'] as String?,
      availableDays: List<String>.from(
        (hall['availableDays'] as List?) ?? const ['Sat', 'Sun'],
      ),
      selectedTimeSlots: List<String>.from(
        (hall['timeSlots'] as List?) ?? const ['day'],
      ),
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
    List<Map<String, dynamic>>? foodPackages,
    List<String>? extraServiceNames,
    List<bool>? extraServiceEnabled,
    List<String>? images,
    Object? virtualTourImage = _unset,
    List<String>? availableDays,
    List<String>? selectedTimeSlots,
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
      foodPackages: foodPackages ?? this.foodPackages,
      extraServiceNames: extraServiceNames ?? this.extraServiceNames,
      extraServiceEnabled: extraServiceEnabled ?? this.extraServiceEnabled,
      images: images ?? this.images,
      virtualTourImage: identical(virtualTourImage, _unset)
          ? this.virtualTourImage
          : virtualTourImage as String?,
      availableDays: availableDays ?? this.availableDays,
      selectedTimeSlots: selectedTimeSlots ?? this.selectedTimeSlots,
    );
  }
}

const Object _unset = Object();

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

  void addFoodPackage(Map<String, dynamic> package) {
    state = state.copyWith(foodPackages: [...state.foodPackages, package]);
  }

  void removeFoodPackageAt(int index) {
    final updated = [...state.foodPackages]..removeAt(index);
    state = state.copyWith(foodPackages: updated);
  }

  void addExtraService(String name) {
    state = state.copyWith(
      extraServiceNames: [...state.extraServiceNames, name],
      extraServiceEnabled: [...state.extraServiceEnabled, true],
    );
  }

  void toggleExtraServiceEnabled(int index, bool value) {
    final updated = [...state.extraServiceEnabled];
    updated[index] = value;
    state = state.copyWith(extraServiceEnabled: updated);
  }

  void removeExtraServiceAt(int index) {
    final names = [...state.extraServiceNames]..removeAt(index);
    final enabled = [...state.extraServiceEnabled]..removeAt(index);
    state = state.copyWith(
      extraServiceNames: names,
      extraServiceEnabled: enabled,
    );
  }

  void addImage(String path) {
    if (state.images.length >= hallFormMaxImages) return;
    state = state.copyWith(images: [...state.images, path]);
  }

  void removeImageAt(int index) {
    final updated = [...state.images]..removeAt(index);
    state = state.copyWith(images: updated);
  }

  void setVirtualTourImage(String path) =>
      state = state.copyWith(virtualTourImage: path);

  void removeVirtualTourImage() =>
      state = state.copyWith(virtualTourImage: null);

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
}

final hallFormControllerProvider = NotifierProvider.autoDispose
    .family<HallFormController, HallFormState, HallFormKey>(
      HallFormController.new,
    );
