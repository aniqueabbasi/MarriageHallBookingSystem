import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/app.dart';

void main() {
  testWidgets('Marriage Hall App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MarriageHallApp()));

    expect(find.byType(MarriageHallApp), findsOneWidget);

    // Let the splash screen's navigation timer finish before disposal.
    await tester.pump(const Duration(seconds: 4));
  });
}
