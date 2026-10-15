import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reassuring card displaying the primary caregiver with a direct call action.
class CaregiverContactCard extends StatelessWidget {
  final String caregiverName;
  final String relationship;
  final String phoneNumber;

  const CaregiverContactCard({
    super.key,
    this.caregiverName = 'Sarah',
    this.relationship = 'Daughter',
    this.phoneNumber = '(555) 234-5678',
  });

  void _handleCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded,
                color: PatientAppTheme.primaryGreen, size: 28),
            const SizedBox(width: 10),
            Text('Calling $caregiverName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connecting you with your $relationship, $caregiverName...',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              phoneNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PatientAppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('End Call',
                style: TextStyle(fontSize: 16, color: PatientAppTheme.helpRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Primary caregiver $caregiverName, your $relationship. Phone number $phoneNumber.',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF15803D).withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.45),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            // Category header badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: PatientAppTheme.softGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFBBF7D0),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: PatientAppTheme.primaryGreen,
                        size: 11,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'PRIMARY CAREGIVER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PatientAppTheme.primaryGreen,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PatientAppTheme.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Caregiver identity + Call action
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;

                final infoSection = Row(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: PatientAppTheme.softGreen,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFBBF7D0),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: PatientAppTheme.primaryGreen,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            caregiverName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: PatientAppTheme.primaryText,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Your $relationship',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: PatientAppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final callButton = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PatientAppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0.5,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _handleCall(context),
                  icon: const Icon(Icons.phone_rounded, size: 20),
                  label: Text('Call $caregiverName',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      infoSection,
                      const SizedBox(height: 14),
                      callButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: infoSection),
                    const SizedBox(width: 12),
                    callButton,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
