import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/authentication/login_screen.dart';

void main() {
  group('PatientLoginScreen Tests', () {
    testWidgets('renders login screen fields and buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientLoginScreen(),
        ),
      );

      expect(find.text('MemoryGuide'), findsOneWidget);
      expect(find.text('Patient Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New patient? Create an account'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientLoginScreen(),
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
          home: PatientLoginScreen(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'notanemail',
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

    testWidgets('toggles to register mode and displays full name field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientLoginScreen(),
        ),
      );

      // Tap create account
      await tester.tap(find.text('New patient? Create an account'));
      await tester.pumpAndSettle();

      expect(find.text('Create Patient Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      // Name, Phone, Email, Password
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);

      // Validate registration fields
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });
  });
}
