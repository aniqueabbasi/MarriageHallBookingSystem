import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';

final hallDetailProvider = FutureProvider.autoDispose.family<Hall, int>(
  (ref, id) => ref.watch(hallsClientProvider).detail(id),
);
