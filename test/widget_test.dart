import 'package:flutter_test/flutter_test.dart';

import 'package:seniors/main.dart';

void main() {
  testWidgets('app shows loading screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Send Love'), findsNothing);
  });
}
