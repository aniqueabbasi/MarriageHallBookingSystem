import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marriage_hall_app/api/clients/users_client.dart';
import 'package:marriage_hall_app/controllers/cnic/cnic_scan_controller.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/cnic/cnic_details.dart';
import 'package:marriage_hall_app/models/cnic/cnic_details_request.dart';
import 'package:marriage_hall_app/models/profile/user_profile.dart';
import 'package:marriage_hall_app/services/cnic_image_picker_service.dart';
import 'package:marriage_hall_app/services/cnic_ocr_service.dart';

class FakeCnicImagePicker implements CnicImagePicker {
  String? cameraResult;
  String? galleryResult;

  @override
  Future<String?> pickFromCamera() async => cameraResult;

  @override
  Future<String?> pickFromGallery() async => galleryResult;
}

class FakeCnicOcrService implements CnicOcrService {
  String? textToReturn;
  Object? errorToThrow;

  @override
  Future<String> recognizeText(String imagePath) async {
    if (errorToThrow != null) throw errorToThrow!;
    return textToReturn ?? '';
  }
}

class FakeUsersClient implements UsersClient {
  Object? errorToThrow;
  CnicDetailsRequest? lastRequest;

  @override
  Future<CnicDetailsResponse> saveCnicDetails(
    CnicDetailsRequest request,
  ) async {
    lastRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
    return const CnicDetailsResponse(
      maskedCnicNumber: '*****-*******-1',
      fullName: 'Test',
    );
  }

  @override
  Future<UserProfile> getMe() => throw UnimplementedError();

  @override
  Future<UserProfile> updateMe(UpdateProfileRequest request) =>
      throw UnimplementedError();
}

CnicDetails _validDetails() => CnicDetails(
  cnicNumber: '12345-1234567-1',
  fullName: 'Ali Raza',
  fatherOrHusbandName: 'Muhammad Raza',
  dateOfBirth: DateTime(2000, 4, 5),
  dateOfIssue: DateTime(2020, 1, 1),
  dateOfExpiry: DateTime(2030, 1, 1),
  gender: 'Male',
);

void main() {
  late FakeCnicImagePicker fakePicker;
  late FakeCnicOcrService fakeOcr;
  late FakeUsersClient fakeUsersClient;
  late ProviderContainer container;

  setUp(() {
    fakePicker = FakeCnicImagePicker();
    fakeOcr = FakeCnicOcrService();
    fakeUsersClient = FakeUsersClient();
    container = ProviderContainer(
      overrides: [
        cnicImagePickerProvider.overrideWithValue(fakePicker),
        cnicOcrServiceProvider.overrideWithValue(fakeOcr),
        usersClientProvider.overrideWithValue(fakeUsersClient),
      ],
    );
  });

  tearDown(() => container.dispose());

  CnicScanController controller() =>
      container.read(cnicScanControllerProvider('test').notifier);
  CnicScanState state() => container.read(cnicScanControllerProvider('test'));

  group('cancellation from picker', () {
    test(
      'leaves state untouched when the gallery picker is cancelled',
      () async {
        fakePicker.galleryResult = null;
        await controller().pickFromGallery();

        expect(state().selectedImagePath, isNull);
        expect(state().errorMessage, isNull);
        expect(state().extractedDetails, isNull);
      },
    );

    test(
      'leaves state untouched when the camera picker is cancelled',
      () async {
        fakePicker.cameraResult = null;
        await controller().pickFromCamera();

        expect(state().selectedImagePath, isNull);
        expect(state().errorMessage, isNull);
      },
    );
  });

  group('scanning failure', () {
    test(
      'scanSelectedImage surfaces a friendly error and stops scanning',
      () async {
        fakePicker.galleryResult = 'some/path.jpg';
        fakeOcr.errorToThrow = Exception('platform channel exploded');

        await controller().pickFromGallery();

        expect(state().isScanning, isFalse);
        expect(state().errorMessage, isNotNull);
        expect(state().extractedDetails, isNull);
        // Never leaks the raw exception text.
        expect(state().errorMessage, isNot(contains('platform channel')));
      },
    );

    test('scanSelectedImage without a selected image sets an error', () async {
      await controller().scanSelectedImage();
      expect(state().errorMessage, isNotNull);
    });

    test('a successful scan clears any previous error', () async {
      fakePicker.galleryResult = 'some/path.jpg';
      fakeOcr.textToReturn = '''
        Name
        Ali Raza
        12345-1234567-1
      ''';

      await controller().pickFromGallery();

      expect(state().errorMessage, isNull);
      expect(state().extractedDetails?.fullName, 'Ali Raza');
      expect(state().extractedDetails?.cnicNumber, '12345-1234567-1');
    });
  });

  group('API submission failure', () {
    test(
      'surfaces a friendly message on ApiException and keeps details for retry',
      () async {
        controller().updateExtractedDetails(_validDetails());
        fakeUsersClient.errorToThrow = const ApiException(
          'Bad data',
          statusCode: 400,
        );

        final result = await controller().submitCnicDetails();

        expect(result, isFalse);
        expect(state().isSubmitting, isFalse);
        expect(state().errorMessage, 'Bad data');
        expect(state().extractedDetails, isNotNull);
        expect(state().submitted, isFalse);
      },
    );

    test('maps a 401 to a session-expired message', () async {
      controller().updateExtractedDetails(_validDetails());
      fakeUsersClient.errorToThrow = const ApiException(
        'nope',
        statusCode: 401,
      );

      await controller().submitCnicDetails();

      expect(state().errorMessage, contains('session has expired'));
    });

    test('surfaces a network error for non-ApiException failures', () async {
      controller().updateExtractedDetails(_validDetails());
      fakeUsersClient.errorToThrow = Exception('socket closed');

      await controller().submitCnicDetails();

      expect(state().errorMessage, contains('Could not reach the server'));
    });

    test('rejects submission when the CNIC number is invalid', () async {
      controller().updateExtractedDetails(
        _validDetails().copyWith(cnicNumber: '123-456-7'),
      );

      final result = await controller().submitCnicDetails();

      expect(result, isFalse);
      expect(state().errorMessage, isNotNull);
    });

    test('rejects submission when required dates are missing', () async {
      controller().updateExtractedDetails(
        CnicDetails(
          cnicNumber: '12345-1234567-1',
          fullName: 'Ali Raza',
          fatherOrHusbandName: 'Muhammad Raza',
          dateOfBirth: DateTime(2000, 4, 5),
          // dateOfIssue / dateOfExpiry left null
        ),
      );

      final result = await controller().submitCnicDetails();
      expect(result, isFalse);
    });

    test('succeeds and clears sensitive state on success', () async {
      controller().updateExtractedDetails(_validDetails());

      final result = await controller().submitCnicDetails();

      expect(result, isTrue);
      expect(state().submitted, isTrue);
      expect(state().extractedDetails, isNull);
      expect(state().extractedRawText, isNull);
      expect(state().selectedImagePath, isNull);
      expect(state().maskedCnicNumber, '*****-*******-1');
      expect(fakeUsersClient.lastRequest?.cnicNumber, '12345-1234567-1');
    });
  });

  group('reset', () {
    test('clears everything back to initial state', () async {
      controller().updateExtractedDetails(_validDetails());
      await controller().reset();

      expect(state().extractedDetails, isNull);
      expect(state().selectedImagePath, isNull);
      expect(state().errorMessage, isNull);
    });
  });
}
