import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_travel/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TravelWorldApp()),
    );
    // Splash screen is the entry point — verify it renders.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TravelWorldApp), findsOneWidget);
  });
}
