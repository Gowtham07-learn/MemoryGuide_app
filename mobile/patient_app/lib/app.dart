import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/patient_home_screen.dart';

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryGuide Patient',
      debugShowCheckedModeBanner: false,
      theme: PatientAppTheme.lightTheme,
      home: const PatientHomeScreen(),
    );
  }
}
