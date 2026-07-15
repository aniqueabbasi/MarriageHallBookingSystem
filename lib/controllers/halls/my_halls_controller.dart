import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';

final myHallsProvider = FutureProvider<List<HallSummary>>(
  (ref) => ref.watch(hallsClientProvider).getMyHalls(),
);
