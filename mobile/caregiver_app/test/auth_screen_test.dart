import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caregiver_app/features/authentication/caregiver_login_screen.dart';

void main() {
  group('CaregiverLoginScreen Tests', () {
    testWidgets('renders caregiver login screen elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CaregiverLoginScreen(),
        ),
      );

      expect(find.text('MemoryGuide'), findsOneWidget);
      expect(find.text('Caregiver Portal Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New caregiver? Register here'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CaregiverLoginScreen(),
        ),
      );

      // Tap Sign In without typing anything
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CaregiverLoginScreen(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Caregiver Email'),
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'pass123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('toggles to caregiver register mode and displays full name field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CaregiverLoginScreen(),
        ),
      );

      // Tap register
      await tester.tap(find.text('New caregiver? Register here'));
      await tester.pumpAndSettle();

      expect(find.text('Register Caregiver Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      // Name, Phone, Email, Password
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Register as Caregiver'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);

      // Validate registration fields
      await tester.tap(find.text('Register as Caregiver'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });
  });
}
