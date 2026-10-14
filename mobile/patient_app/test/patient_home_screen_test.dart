import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/home/patient_home_screen.dart';

void main() {
  group('PatientHomeScreen State & Accessibility Tests', () {
    testWidgets('renders all core UI elements on home screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientHomeScreen(isDevMode: false),
        ),
      );

      // MemoryGuide title
      expect(find.text('MemoryGuide'), findsOneWidget);

      // Orientation Header (Arthur greeting)
      expect(find.textContaining('Arthur'), findsOneWidget);

      // Safe Zone banner (initial is Inside Home)
      expect(find.text('You are safe'), findsOneWidget);
      expect(find.text('Inside Home (Maple Street)'), findsOneWidget);

      // Caregiver card
      expect(find.text('Sarah'), findsOneWidget);
      expect(find.text('Your Daughter'), findsOneWidget);
      expect(find.text('Call Sarah'), findsOneWidget);

      // Familiar Voice card
      expect(find.text('Familiar Voice'), findsOneWidget);
      expect(find.text('Listen to a familiar voice message'), findsOneWidget);
      expect(find.text('Play Voice'), findsOneWidget);

      // Emergency Help button
      expect(find.text('CALL HELP'), findsOneWidget);

      // In production mode (isDevMode: false), the simulator tool icon is NOT exposed to patients
      expect(find.byTooltip('Toggle Demo Simulator'), findsNothing);
    });

    testWidgets(
        'exposes simulator tool only when isDevMode is true and allows switching states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientHomeScreen(isDevMode: true),
        ),
      );

      // Simulator icon is visible in dev mode
      final simulatorButton = find.byTooltip('Toggle Demo Simulator');
      expect(simulatorButton, findsOneWidget);

      // Initially simulator panel is closed
      expect(find.text('🧪 Live Status Simulator'), findsNothing);

      // Tap to open simulator
      await tester.tap(simulatorButton);
      await tester.pumpAndSettle();

      expect(find.text('🧪 Live Status Simulator'), findsOneWidget);
      expect(find.text('Inside Home'), findsOneWidget);
      expect(find.text('Outside Zone'), findsOneWidget);
      expect(find.text('Locating GPS'), findsOneWidget);
      expect(find.text('Location Paused'), findsOneWidget);
      expect(find.text('Signal Delayed'), findsOneWidget);

      // Switch to Signal Delayed (Stale)
      await tester.ensureVisible(find.text('Signal Delayed'));
      await tester.tap(find.text('Signal Delayed'));
      await tester.pumpAndSettle();

      expect(find.text('Location unverified'), findsOneWidget);
      expect(find.text('You are safe'), findsNothing);

      // Switch to Outside Zone
      await tester.ensureVisible(find.text('Outside Zone'));
      await tester.tap(find.text('Outside Zone'));
      await tester.pumpAndSettle();

      expect(find.text('Outside safe zone'), findsOneWidget);
      expect(find.text('Your family knows where you are'), findsOneWidget);

      // Switch back to Inside Home
      await tester.ensureVisible(find.text('Inside Home'));
      await tester.tap(find.text('Inside Home'));
      await tester.pumpAndSettle();

      expect(find.text('You are safe'), findsOneWidget);
    });
  });
}
