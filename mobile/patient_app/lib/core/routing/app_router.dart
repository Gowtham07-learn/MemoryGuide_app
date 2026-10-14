import 'package:flutter/material.dart';
import '../../features/home/patient_home_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      default:
        return MaterialPageRoute(builder: (_) => const PatientHomeScreen());
    }
  }
}
