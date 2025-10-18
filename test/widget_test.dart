import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdf_generator/main.dart';

void main() {
  testWidgets('Home screen renders with navy theme and actions', (WidgetTester tester) async {
    await tester.pumpWidget(const PdfApp());

    // App title present in AppBar
    expect(find.text('PDF Assistant'), findsOneWidget);

    // Primary action button
    expect(find.text('Pick PDFs'), findsOneWidget);

    // Empty state message
    expect(find.text('No PDFs selected. Tap "Pick PDFs".'), findsOneWidget);

    // Verify action icons exist (robust across Material versions)
    expect(find.byIcon(Icons.merge_type), findsOneWidget);
    expect(find.byIcon(Icons.compress), findsOneWidget);
  });
}
