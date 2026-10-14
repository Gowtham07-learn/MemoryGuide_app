import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/data/models/safe_zone_state.dart';
import 'package:patient_app/features/safe_zones/safe_zone_banner.dart';

void main() {
  group('SafeZoneBanner Widget Tests', () {
    testWidgets('displays reassuring message when inside safe zone',
        (WidgetTester tester) async {
      const info = SafeZoneInfo(
        status: SafeZoneStatus.inside,
        zoneName: 'Sweet Home',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(find.text('You are safe'), findsOneWidget);
      expect(find.text('Inside Sweet Home'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('displays clear notification when outside safe zone',
        (WidgetTester tester) async {
      const info = SafeZoneInfo(
        status: SafeZoneStatus.outside,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(find.text('Outside safe zone'), findsOneWidget);
      expect(find.text('Your family knows where you are'), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('displays locating status when GPS is searching',
        (WidgetTester tester) async {
      const info = SafeZoneInfo(
        status: SafeZoneStatus.locating,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(find.text('Finding your location'), findsOneWidget);
      expect(find.text('Please wait a moment...'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });

    testWidgets('displays warning when location is paused or disabled',
        (WidgetTester tester) async {
      const info = SafeZoneInfo(
        status: SafeZoneStatus.unavailable,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(find.text('Location paused'), findsOneWidget);
      expect(find.text('Check if phone GPS is on'), findsOneWidget);
      expect(find.byIcon(Icons.location_off_rounded), findsOneWidget);
    });

    testWidgets(
        'displays unverified status when explicitly marked stale and never shows You are safe',
        (WidgetTester tester) async {
      const info = SafeZoneInfo(
        status: SafeZoneStatus.stale,
        zoneName: 'Sweet Home',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(find.text('Location unverified'), findsOneWidget);
      expect(find.text('Last known at Sweet Home. Reconnecting...'),
          findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.text('You are safe'), findsNothing);
    });

    testWidgets(
        'automatically marks old timestamp as stale and never displays You are safe',
        (WidgetTester tester) async {
      final info = SafeZoneInfo(
        status: SafeZoneStatus.inside,
        zoneName: 'Sweet Home',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(find.text('Location unverified'), findsOneWidget);
      expect(find.text('You are safe'), findsNothing);
      expect(info.isSafe, isFalse);
    });

    testWidgets('provides accessible screen-reader semantics on banner',
        (WidgetTester tester) async {
      const info = SafeZoneInfo(
        status: SafeZoneStatus.inside,
        zoneName: 'Maple Street',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SafeZoneBanner(info: info)),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp(
            'Safety Status: You are safe. Inside Maple Street. Safe Area Active')),
        findsOneWidget,
      );
    });
  });
}
