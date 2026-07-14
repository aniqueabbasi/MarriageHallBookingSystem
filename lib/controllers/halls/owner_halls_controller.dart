import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/data/dummy/owner_hall_dummy_data.dart';

class OwnerHallsController extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() =>
      List<Map<String, dynamic>>.from(dummyOwnerHalls);

  void addHall(Map<String, dynamic> hall) => state = [...state, hall];

  void updateHall(int index, Map<String, dynamic> hall) {
    final updated = [...state];
    updated[index] = hall;
    state = updated;
  }

  void deleteHall(int index) {
    final updated = [...state]..removeAt(index);
    state = updated;
  }
}

final ownerHallsControllerProvider =
    NotifierProvider<OwnerHallsController, List<Map<String, dynamic>>>(
      OwnerHallsController.new,
    );
