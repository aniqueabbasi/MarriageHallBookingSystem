import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerProfileController extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {
    'name': 'Ahmed Raza',
    'email': 'ahmed.raza@example.com',
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

final ownerProfileControllerProvider =
    NotifierProvider<OwnerProfileController, Map<String, dynamic>>(
      OwnerProfileController.new,
    );
