import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/help/emergency_sos_button.dart';

void main() {
  group('EmergencySosButton Widget Tests', () {
    testWidgets('renders initial red Help button with accessible labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: EmergencySosButton()),
          ),
        ),
      );

      expect(find.text('CALL HELP'), findsOneWidget);
      expect(find.text('Tap for emergency help'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets(
        'displays honest demo dialog and never claims caregiver notification in demo mode',
        (WidgetTester tester) async {
      bool triggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EmergencySosButton(
                onTriggered: () {
                  triggered = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap the help button
      await tester.tap(find.text('CALL HELP'));
      await tester.pumpAndSettle();

      expect(triggered, isTrue);

      // Verify honest demonstration dialog title and explanation
      expect(find.text('Emergency Help (Demo Mode)'), findsOneWidget);
      expect(
        find.text(
            'This application is running in demonstration mode and is not connected to a live alert service.'),
        findsOneWidget,
      );
      expect(
        find.text('No caregiver or emergency services have been notified.'),
        findsOneWidget,
      );

      // Verify absence of any false claims
      expect(
          find.text(
              'Your caregiver and emergency contacts have been notified with your live GPS location.'),
          findsNothing);
      expect(find.text('Help Alert Sent!'), findsNothing);

      // Reset action
      expect(find.text('Understood (Reset)'), findsOneWidget);
      await tester.tap(find.text('Understood (Reset)'));
      await tester.pumpAndSettle();

      // Dialog dismissed, button returns to ready state
      expect(find.text('CALL HELP'), findsOneWidget);
    });

    testWidgets('prevents repeated submissions while a request is in progress',
        (WidgetTester tester) async {
      final completer = Completer<void>();
      int triggerCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EmergencySosButton(
                onTriggered: () {
                  triggerCount++;
                  return completer.future;
                },
              ),
            ),
          ),
        ),
      );

      // First tap begins async dispatch
      await tester.tap(find.text('CALL HELP'));
      await tester.pump(); // Start execution

      // While request is in flight, loading indicator and text are visible
      expect(find.text('SENDING...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(triggerCount, equals(1));

      // Attempt repeated tap while in flight
      await tester.tap(find.text('SENDING...'));
      await tester.pump();

      // Should NOT have triggered again
      expect(triggerCount, equals(1));

      // Complete async operation
      completer.complete();
      await tester.pumpAndSettle();

      // Dialog opens once completed
      expect(find.text('Emergency Help (Demo Mode)'), findsOneWidget);
    });

    testWidgets('communicates errors clearly when dispatch fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EmergencySosButton(
                onTriggered: () async {
                  throw Exception('Network unreachable');
                },
              ),
            ),
          ),
        ),
      );

      // Tap button to trigger failure
      await tester.tap(find.text('CALL HELP'));
      await tester.pumpAndSettle();

      // Error dialog displayed
      expect(find.text('Unable to Send Alert'), findsOneWidget);
      expect(
        find.text(
            'A problem occurred while processing your emergency request. The alert could not be verified.'),
        findsOneWidget,
      );
      expect(find.text('Help Alert Sent!'), findsNothing);

      // Close error dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Button returns to ready state allowing retry
      expect(find.text('CALL HELP'), findsOneWidget);
    });

    testWidgets(
        'handles connected mode without falsely claiming delivery confirmation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: EmergencySosButton(
                isDemoMode: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CALL HELP'));
      await tester.pumpAndSettle();

      // Connected mode title and honest pending acknowledgment note
      expect(find.text('Help Request Sent'), findsOneWidget);
      expect(
        find.text(
            'Your help request was sent to the server and is awaiting caregiver acknowledgment.'),
        findsOneWidget,
      );
      expect(
        find.text('Waiting for caregiver confirmation. Please stay safe.'),
        findsOneWidget,
      );

      // Never claims caregiver has received/acknowledged yet
      expect(
          find.textContaining('have been notified with your live GPS location'),
          findsNothing);

      await tester.tap(find.text('I am Safe Now (Reset)'));
      await tester.pumpAndSettle();

      expect(find.text('CALL HELP'), findsOneWidget);
    });
  });
}
