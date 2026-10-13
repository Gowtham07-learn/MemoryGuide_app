import 'package:flutter/material.dart';

class PatientLoginScreen extends StatelessWidget {
  const PatientLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Sign In')),
      body: const Center(child: Text('Sign In Screen')),
    );
  }
}
