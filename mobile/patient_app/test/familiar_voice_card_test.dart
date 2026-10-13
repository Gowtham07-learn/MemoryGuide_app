import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/home/familiar_voice_card.dart';

void main() {
  group('FamiliarVoiceCard Widget Tests', () {
    testWidgets(
        'renders card with speaker icon, title, description, and Play Voice button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: FamiliarVoiceCard()),
          ),
        ),
      );

      // Verify headings and labels
      expect(find.text('Familiar Voice'), findsOneWidget);
      expect(find.text('Listen to a familiar voice message'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      expect(find.text('Play Voice'), findsOneWidget);
    });

    testWidgets(
        'displays honest dialog when no recording is configured without false playback claims',
        (WidgetTester tester) async {
      bool playCallbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FamiliarVoiceCard(
                onPlayPressed: () {
                  playCallbackFired = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap Play Voice
      await tester.tap(find.text('Play Voice'));
      await tester.pumpAndSettle();

      expect(playCallbackFired, isTrue);

      // Verify honest dialog appears
      expect(find.text('Voice Message Not Available'), findsOneWidget);
      expect(
        find.text(
            'Your caregiver has not recorded a familiar voice message yet.'),
        findsOneWidget,
      );

      // Dismiss dialog
      expect(find.text('Understood'), findsOneWidget);
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      // Dialog dismissed, button returns to Play Voice
      expect(find.text('Play Voice'), findsOneWidget);
    });

    testWidgets('provides accessible screen-reader semantics on the card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: FamiliarVoiceCard()),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
            RegExp('Familiar Voice message card.*Play Voice')),
        findsOneWidget,
      );
    });
  });
}
