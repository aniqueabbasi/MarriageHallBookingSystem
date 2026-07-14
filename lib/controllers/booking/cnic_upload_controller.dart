import 'package:flutter_riverpod/flutter_riverpod.dart';

class CnicUploadState {
  final bool cnicUploaded;
  final bool showCnicError;

  const CnicUploadState({
    this.cnicUploaded = false,
    this.showCnicError = false,
  });

  CnicUploadState copyWith({bool? cnicUploaded, bool? showCnicError}) {
    return CnicUploadState(
      cnicUploaded: cnicUploaded ?? this.cnicUploaded,
      showCnicError: showCnicError ?? this.showCnicError,
    );
  }
}

class CnicUploadController extends Notifier<CnicUploadState> {
  @override
  CnicUploadState build() => const CnicUploadState();

  void pickCnicPicture() {
    state = state.copyWith(cnicUploaded: true, showCnicError: false);
  }

  void removeCnicPicture() {
    state = state.copyWith(cnicUploaded: false);
  }

  void setShowError(bool value) {
    state = state.copyWith(showCnicError: value);
  }
}

/// Keyed by a unique per-screen-instance token.
final cnicUploadControllerProvider = NotifierProvider.autoDispose
    .family<CnicUploadController, CnicUploadState, String>(
      (instanceId) => CnicUploadController(),
    );
