import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Thin wrapper around [ImagePicker] scoped to the CNIC scan flow. Kept as
/// an interface so tests can fake "user cancelled the picker" without a
/// real platform channel.
abstract class CnicImagePicker {
  /// Returns the picked image's file path, or null if the user cancelled.
  Future<String?> pickFromCamera();

  /// Returns the picked image's file path, or null if the user cancelled.
  Future<String?> pickFromGallery();
}

class DefaultCnicImagePicker implements CnicImagePicker {
  final _picker = ImagePicker();

  @override
  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return file?.path;
  }

  @override
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return file?.path;
  }
}

final cnicImagePickerProvider = Provider<CnicImagePicker>(
  (ref) => DefaultCnicImagePicker(),
);
