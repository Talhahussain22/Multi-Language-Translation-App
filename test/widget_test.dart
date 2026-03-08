import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_text_to_speech/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);

    // Dispose to avoid leaving background widgets running (ads/timers).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
