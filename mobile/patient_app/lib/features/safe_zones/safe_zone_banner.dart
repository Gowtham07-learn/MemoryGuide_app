import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/safe_zone_state.dart';

/// A patient-friendly status banner displaying whether the patient is
/// currently inside or outside their designated safe area, or if location is being acquired.
class SafeZoneBanner extends StatelessWidget {
  final SafeZoneInfo info;

  const SafeZoneBanner({
    super.key,
    required this.info,
  });

  /// Convenience constructor allowing backward compatibility with simple boolean calls.
  factory SafeZoneBanner.fromSimple({
    Key? key,
    required bool isSafe,
    required String safeZoneName,
  }) {
    return SafeZoneBanner(
      key: key,
      info: SafeZoneInfo(
        status: isSafe ? SafeZoneStatus.inside : SafeZoneStatus.outside,
        zoneName: safeZoneName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannerConfig = _getBannerConfig(info);
    final semanticLabel =
        'Safety Status: ${bannerConfig.title}. ${bannerConfig.subtitle ?? ""}. ${bannerConfig.statusLabel}';
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: bannerConfig.backgroundColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: bannerConfig.contentColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top status pill badge: clear textual status for non-color accessibility
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: bannerConfig.contentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: bannerConfig.contentColor.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: bannerConfig.contentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: bannerConfig.contentColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            bannerConfig.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: bannerConfig.contentColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'SAFETY STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: bannerConfig.contentColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hero content: Elevated icon badge + Title + Supporting location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  bannerConfig.contentColor.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          bannerConfig.icon,
                          color: bannerConfig.contentColor,
                          size: 32,
                        ),
                      ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bannerConfig.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: bannerConfig.contentColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (bannerConfig.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          bannerConfig.subtitle!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            color: bannerConfig.contentColor
                                .withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  _BannerDisplayConfig _getBannerConfig(SafeZoneInfo info) {
    switch (info.effectiveStatus) {
      case SafeZoneStatus.inside:
        final zone = info.zoneName ?? 'Safe Area';
        return _BannerDisplayConfig(
          title: 'You are safe',
          subtitle: 'Inside $zone',
          statusLabel: 'Safe Area Active',
          icon: Icons.check_circle_rounded,
          contentColor: PatientAppTheme.primaryGreen,
          backgroundColor: PatientAppTheme.softGreen,
          borderColor: const Color(0xFF86EFAC),
        );

      case SafeZoneStatus.outside:
        return const _BannerDisplayConfig(
          title: 'Outside safe zone',
          subtitle: 'Your family knows where you are',
          statusLabel: 'Outside Designated Area',
          icon: Icons.info_rounded,
          contentColor: PatientAppTheme.helpRed,
          backgroundColor: PatientAppTheme.softRed,
          borderColor: Color(0xFFFECACA),
        );

      case SafeZoneStatus.locating:
        return const _BannerDisplayConfig(
          title: 'Finding your location',
          subtitle: 'Please wait a moment...',
          statusLabel: 'Acquiring GPS Signal',
          icon: Icons.sync_rounded,
          contentColor: PatientAppTheme.primaryBlue,
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
        );

      case SafeZoneStatus.unavailable:
        return const _BannerDisplayConfig(
          title: 'Location paused',
          subtitle: 'Check if phone GPS is on',
          statusLabel: 'Location Services Paused',
          icon: Icons.location_off_rounded,
          contentColor: Color(0xFFB45309),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
        );

      case SafeZoneStatus.stale:
        final lastKnown = info.zoneName != null
            ? 'Last known at ${info.zoneName}'
            : 'Waiting for recent GPS update';
        return _BannerDisplayConfig(
          title: 'Location unverified',
          subtitle: '$lastKnown. Reconnecting...',
          statusLabel: 'Signal Delayed',
          icon: Icons.history_rounded,
          contentColor: const Color(0xFF92400E),
          backgroundColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFCD34D),
        );
    }
  }
}

class _BannerDisplayConfig {
  final String title;
  final String? subtitle;
  final String statusLabel;
  final IconData icon;
  final Color contentColor;
  final Color backgroundColor;
  final Color borderColor;

  const _BannerDisplayConfig({
    required this.title,
    this.subtitle,
    required this.statusLabel,
    required this.icon,
    required this.contentColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
