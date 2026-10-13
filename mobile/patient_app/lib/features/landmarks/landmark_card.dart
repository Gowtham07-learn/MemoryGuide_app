import 'package:flutter/material.dart';

class LandmarkCard extends StatelessWidget {
  final String name;
  const LandmarkCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(name)));
  }
}
