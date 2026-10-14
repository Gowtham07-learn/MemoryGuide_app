import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

/// Large, calming orientation header to reduce time and situational disorientation.
class OrientationHeader extends StatelessWidget {
  final String patientName;

  const OrientationHeader({
    super.key,
    this.patientName = 'Arthur',
  });

  String _getTimeGreeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getTimeGreeting(now);
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return Semantics(
      container: true,
      label: '$greeting, $patientName. Today is $formattedDate.',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calming date badge with calendar icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: PatientAppTheme.primaryBlue,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PatientAppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Welcoming patient greeting headline
            Text(
              '$greeting, $patientName',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: PatientAppTheme.deepNavy,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),

            // Reassuring orientation companion text
            const Text(
              'Here is your status and care circle for today.',
              style: TextStyle(
                fontSize: 15,
                color: PatientAppTheme.secondaryText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
