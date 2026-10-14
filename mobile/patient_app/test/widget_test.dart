import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/app.dart';

void main() {
  testWidgets('PatientApp loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PatientApp());
    expect(find.text('MemoryGuide'), findsOneWidget);
  });
}
