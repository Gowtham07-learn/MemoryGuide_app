import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  const StatusIndicator({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 6,
      backgroundColor: isOnline ? Colors.green : Colors.grey,
    );
  }
}
