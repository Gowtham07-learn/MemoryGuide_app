import 'package:caregiver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'dashboard renders, completes care tasks, and opens appointment',
    (tester) async {
      await tester.pumpWidget(const MemoryGuideApp());

      expect(find.text('MemoryGuide'), findsOneWidget);
      expect(find.text('Today’s rhythm'), findsOneWidget);
      expect(find.text('Morning walk'), findsOneWidget);

      await tester.ensureVisible(find.text('Breakfast'));
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 3 moments completed'), findsOneWidget);

      await tester.ensureVisible(find.text('Doctor’s visit'));
      await tester.tap(find.text('Doctor’s visit'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Dr. Patel'), findsWidgets);
      expect(find.text('Close'), findsOneWidget);
    },
  );

  testWidgets('appointment can be created, edited, completed, and synced', (
    tester,
  ) async {
    await tester.pumpWidget(const MemoryGuideApp());
    await _openTab(tester, 'Schedule');

    await tester.tap(find.text('Add appointment'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Follow-up visit');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Community clinic',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Follow-up visit'), findsOneWidget);

    await _openTab(tester, 'Home');
    expect(find.text('Follow-up visit'), findsOneWidget);

    await _openTab(tester, 'Schedule');
    await tester.tap(find.byTooltip('Edit appointment').first);
    await tester.pumpAndSettle();
    final titleField = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .first;
    await tester.enterText(find.byWidget(titleField), 'Updated follow-up');
    await tester.enterText(find.byType(TextFormField).at(1), 'Westside clinic');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Updated follow-up'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark appointment as completed').first);
    await tester.pumpAndSettle();
    final completedTitle = tester.widget<Text>(find.text('Updated follow-up'));
    expect(completedTitle.style?.decoration, TextDecoration.lineThrough);

    await _openTab(tester, 'Home');
    expect(find.text('Updated follow-up'), findsNothing);
    expect(find.text('Doctor’s visit'), findsOneWidget);
  });

  testWidgets('blank appointment title is rejected', (tester) async {
    await tester.pumpWidget(const MemoryGuideApp());
    await _openTab(tester, 'Schedule');
    await tester.tap(find.text('Add appointment'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an appointment title.'), findsOneWidget);
    expect(find.text('Add appointment'), findsWidgets);
  });

  testWidgets(
    'medication required fields are validated and deletion confirmed',
    (tester) async {
      await tester.pumpWidget(const MemoryGuideApp());
      await _openTab(tester, 'Medicine');

      await tester.tap(find.text('Add Medication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a medication name.'), findsOneWidget);
      expect(find.text('Enter the medication dosage.'), findsOneWidget);
      expect(find.text('Add Medication'), findsWidgets);

      await tester.enterText(find.byType(TextFormField).at(0), 'Vitamin D');
      await tester.enterText(find.byType(TextFormField).at(1), '1 capsule');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Vitamin D'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete medication'));
      await tester.pumpAndSettle();
      expect(find.text('Delete medication?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Vitamin D'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete medication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No medications added yet.'), findsOneWidget);
    },
  );

  testWidgets('profile avatar and Profile navigation open Profile tab', (
    tester,
  ) async {
    await tester.pumpWidget(const MemoryGuideApp());

    await tester.tap(find.byTooltip('View profile'));
    await tester.pumpAndSettle();
    expect(find.text('A little about Elaine'), findsOneWidget);
    expect(find.text('Sarah Brooks'), findsOneWidget);

    await _openTab(tester, 'Home');
    await _openTab(tester, 'Profile');
    expect(find.text('A little about Elaine'), findsOneWidget);
  });

  testWidgets('dashboard, Schedule, and Medications fit mobile and desktop', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MemoryGuideApp());

    for (final viewport in [const Size(320, 800), const Size(1200, 900)]) {
      await _setViewport(tester, viewport);
      expect(tester.takeException(), isNull, reason: 'Dashboard at $viewport');

      await _openTab(tester, 'Schedule');
      expect(tester.takeException(), isNull, reason: 'Schedule at $viewport');

      await _openTab(tester, 'Medicine');
      expect(
        tester.takeException(),
        isNull,
        reason: 'Medications at $viewport',
      );

      await _openTab(tester, 'Home');
    }
  });
}
