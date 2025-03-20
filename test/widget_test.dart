import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/widgets/counter_widget.dart'; // Adjust based on your project structure

void main() {
  testWidgets('Counter increments when button is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

    // Verify initial counter value
    expect(find.text('0'), findsOneWidget);

    // Tap the increment button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify updated counter value
    expect(find.text('1'), findsOneWidget);
  });
}
