import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileController extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {
    'name': 'Ayesha Khan',
    'email': 'ayesha.khan@example.com',
    'phone': '0300 1234567',
    'city': 'Lahore',
  };

  void update({
    required String name,
    required String email,
    required String phone,
    required String city,
  }) {
    state = {'name': name, 'email': email, 'phone': phone, 'city': city};
  }
}

final userProfileControllerProvider =
    NotifierProvider<UserProfileController, Map<String, dynamic>>(
      UserProfileController.new,
    );
