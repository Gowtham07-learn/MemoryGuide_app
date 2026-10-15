import 'package:flutter/material.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'data/models/patient_model.dart';
import 'features/authentication/login_screen.dart';
import 'features/home/patient_home_screen.dart';

class PatientApp extends StatefulWidget {
  final Widget? home;
  const PatientApp({super.key, this.home});

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  late Future<UserModel?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = PatientAppServices.instance.authRepository.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryGuide Patient',
      debugShowCheckedModeBanner: false,
      theme: PatientAppTheme.lightTheme,
      home: widget.home ??
          FutureBuilder<UserModel?>(
            future: _sessionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: PatientAppTheme.background,
                  appBar: AppBar(
                    title: const Text('MemoryGuide'),
                    centerTitle: true,
                  ),
                  body: const Center(
                    child: CircularProgressIndicator(
                      color: PatientAppTheme.primaryBlue,
                    ),
                  ),
                );
              }
              final user = snapshot.data;
              if (user != null && user.role == 'patient') {
                return const PatientHomeScreen();
              }
              return const PatientLoginScreen();
            },
          ),
    );
  }
}
