import 'package:flutter/material.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/home/patient_home_screen.dart';

class AppRouter {
  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const PatientLoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const PatientHomeScreen());
      case initial:
      default:
        return MaterialPageRoute(builder: (_) => const PatientLoginScreen());
    }
  }
}
