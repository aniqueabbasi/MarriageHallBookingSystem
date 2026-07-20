import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/users_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/cnic/cnic_details.dart';
import 'package:marriage_hall_app/models/cnic/cnic_details_request.dart';
import 'package:marriage_hall_app/services/cnic_image_picker_service.dart';
import 'package:marriage_hall_app/services/cnic_ocr_service.dart';
import 'package:marriage_hall_app/utils/cnic_parser.dart';

class CnicScanState {
  final String? selectedImagePath;
  final bool isScanning;
  final String? extractedRawText;
  final CnicDetails? extractedDetails;
  final String? errorMessage;
  final bool isSubmitting;
  final bool submitted;

  /// Set only once [submitted] becomes true — the already-masked number
  /// (e.g. "*****-*******-1"), kept around purely for display so the UI
  /// can confirm what was saved without retaining the real CNIC number
  /// anywhere in memory after a successful submit.
  final String? maskedCnicNumber;

  const CnicScanState({
    this.selectedImagePath,
    this.isScanning = false,
    this.extractedRawText,
    this.extractedDetails,
    this.errorMessage,
    this.isSubmitting = false,
    this.submitted = false,
    this.maskedCnicNumber,
  });

  CnicScanState copyWith({
    String? selectedImagePath,
    bool? isScanning,
    String? extractedRawText,
    CnicDetails? extractedDetails,
    String? errorMessage,
    bool? isSubmitting,
    bool? submitted,
    String? maskedCnicNumber,
  }) {
    return CnicScanState(
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      isScanning: isScanning ?? this.isScanning,
      extractedRawText: extractedRawText ?? this.extractedRawText,
      extractedDetails: extractedDetails ?? this.extractedDetails,
      // Always overwritten (including with null) so callers can clear it —
      // same idiom as AuthState.copyWith elsewhere in this app.
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitted: submitted ?? this.submitted,
      maskedCnicNumber: maskedCnicNumber ?? this.maskedCnicNumber,
    );
  }
}

/// Drives the whole scan -> verify -> submit flow for one CNIC scanning
/// session. Keyed per screen instance (family) so multiple in-flight
/// flows never share state — the same pattern the booking flow already
/// uses for its own per-instance controllers (see CnicUploadController's
/// replacement usage in booking_confirmation_screen.dart).
///
/// Nothing here ever touches disk/secure storage itself: the image path,
/// OCR text, and parsed fields live only in this in-memory state and are
/// gone the moment [reset] runs, submission succeeds, or the provider is
/// disposed (it's `autoDispose`). The picked image file is only ever
/// deleted when it came from the camera (a real temp file this app is
/// responsible for) — gallery picks are the user's own photo library and
/// are never touched.
class CnicScanController extends Notifier<CnicScanState> {
  bool _lastPickWasCamera = false;

  @override
  CnicScanState build() => const CnicScanState();

  Future<void> pickFromCamera() => _pick(fromCamera: true);

  Future<void> pickFromGallery() => _pick(fromCamera: false);

  Future<void> _pick({required bool fromCamera}) async {
    final picker = ref.read(cnicImagePickerProvider);
    final path = fromCamera
        ? await picker.pickFromCamera()
        : await picker.pickFromGallery();

    // User backed out of the picker — leave whatever state already
    // existed untouched rather than treating this as an error.
    if (path == null) return;

    // A retake replaces the previous pick — clean up its temp file first
    // so repeated retakes don't leave orphaned camera captures behind.
    await _deleteTempCameraFile();

    _lastPickWasCamera = fromCamera;
    state = CnicScanState(selectedImagePath: path);
    await scanSelectedImage();
  }

  Future<void> scanSelectedImage() async {
    final imagePath = state.selectedImagePath;
    if (imagePath == null) {
      state = state.copyWith(
        errorMessage: 'Select or capture a CNIC photo first.',
      );
      return;
    }

    state = state.copyWith(isScanning: true, errorMessage: null);

    try {
      final rawText = await ref
          .read(cnicOcrServiceProvider)
          .recognizeText(imagePath);
      final details = extractCnicDetails(rawText);
      state = state.copyWith(
        isScanning: false,
        extractedRawText: rawText,
        extractedDetails: details,
      );
    } catch (_) {
      // Never surface the raw exception — it could echo file paths or
      // platform internals, and there's no CNIC data in it to justify
      // the risk anyway.
      state = state.copyWith(
        isScanning: false,
        errorMessage:
            'Could not read the CNIC photo. Try again with better '
            'lighting, or enter the details manually.',
      );
    }
  }

  void updateExtractedDetails(CnicDetails updated) {
    state = state.copyWith(extractedDetails: updated, errorMessage: null);
  }

  /// Validates the confirmed fields one last time, then submits only the
  /// structured JSON — never the image. Returns whether it succeeded so
  /// the screen can navigate/show a snackbar without re-reading state.
  Future<bool> submitCnicDetails() async {
    if (state.isSubmitting) return false;

    final details = state.extractedDetails;
    if (details == null) {
      state = state.copyWith(
        errorMessage: 'Fill in the CNIC details before continuing.',
      );
      return false;
    }
    if (!isValidCnicFormat(details.cnicNumber)) {
      state = state.copyWith(
        errorMessage: 'Enter a valid CNIC number (XXXXX-XXXXXXX-X).',
      );
      return false;
    }
    if (details.dateOfBirth == null ||
        details.dateOfIssue == null ||
        details.dateOfExpiry == null) {
      state = state.copyWith(
        errorMessage: 'Fill in all three CNIC dates before continuing.',
      );
      return false;
    }
    if (details.fullName.trim().isEmpty ||
        details.fatherOrHusbandName.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: 'Fill in the name and father/husband name.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await ref
          .read(usersClientProvider)
          .saveCnicDetails(CnicDetailsRequest.fromDetails(details));

      // Success — the image and OCR text are cleared from memory (and
      // disk, if it was a camera capture) immediately; nothing sensitive
      // needs to survive past a successful submit except the already-
      // masked number, kept only for display.
      final masked = details.maskedCnicNumber;
      await _deleteTempCameraFile();
      state = CnicScanState(submitted: true, maskedCnicNumber: masked);
      return true;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        400 => e.message,
        401 => 'Your session has expired. Please log in again.',
        404 => 'Your account could not be found. Please log in again.',
        _ => 'Could not save your CNIC details. Please try again.',
      };
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            'Could not reach the server. Check your connection and try again.',
      );
      return false;
    }
  }

  /// Clears the image, OCR text, and parsed fields from memory — used on
  /// explicit cancel, and implicitly satisfied on successful submit and
  /// on provider disposal (autoDispose).
  Future<void> reset() async {
    await _deleteTempCameraFile();
    state = const CnicScanState();
  }

  Future<void> _deleteTempCameraFile() async {
    final path = state.selectedImagePath;
    if (!_lastPickWasCamera || path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best-effort cleanup only — never let this surface to the user.
    }
  }
}

/// Keyed per screen instance so concurrent CNIC flows never share state.
final cnicScanControllerProvider = NotifierProvider.autoDispose
    .family<CnicScanController, CnicScanState, String>(
      (instanceId) => CnicScanController(),
    );
