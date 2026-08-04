import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/main.dart';

void main() {
  testWidgets('Talbatiyk app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TalbatiykApp()));
    await tester.pump();

    expect(find.byType(TalbatiykApp), findsOneWidget);
  });
}
