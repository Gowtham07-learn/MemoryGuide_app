import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/safe_zone_state.dart';
import '../help/emergency_sos_button.dart';
import '../safe_zones/safe_zone_banner.dart';
import 'caregiver_contact_card.dart';
import 'familiar_voice_card.dart';
import 'orientation_header.dart';

class PatientHomeScreen extends StatefulWidget {
  final SafeZoneInfo? safeZoneInfo;

  /// Controls visibility of developer preview controls.
  /// Defaults to [kDebugMode], hiding simulator tools in production builds.
  final bool isDevMode;

  const PatientHomeScreen({
    super.key,
    this.safeZoneInfo,
    this.isDevMode = kDebugMode,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late SafeZoneInfo _currentSafeZoneInfo;
  bool _showSimulator = false;

  @override
  void initState() {
    super.initState();
    _currentSafeZoneInfo = widget.safeZoneInfo ??
        const SafeZoneInfo(
          status: SafeZoneStatus.inside,
          zoneName: 'Home (Maple Street)',
        );
  }

  @override
  void didUpdateWidget(covariant PatientHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.safeZoneInfo != null &&
        widget.safeZoneInfo != oldWidget.safeZoneInfo) {
      _currentSafeZoneInfo = widget.safeZoneInfo!;
    }
  }

  void _setStatus(SafeZoneStatus status, [String? zoneName]) {
    setState(() {
      _currentSafeZoneInfo = SafeZoneInfo(
        status: status,
        zoneName: zoneName,
        lastUpdated: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientAppTheme.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_rounded,
              color: PatientAppTheme.primaryBlue,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'MemoryGuide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: PatientAppTheme.deepNavy,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        backgroundColor: PatientAppTheme.cardBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: PatientAppTheme.borders,
          ),
        ),
        actions: [
          if (widget.isDevMode)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                tooltip: 'Toggle Demo Simulator',
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _showSimulator
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _showSimulator
                          ? const Color(0xFFBFDBFE)
                          : PatientAppTheme.borders,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _showSimulator ? Icons.tune_rounded : Icons.tune_outlined,
                    size: 20,
                    color: _showSimulator
                        ? PatientAppTheme.primaryBlue
                        : PatientAppTheme.secondaryText,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showSimulator = !_showSimulator;
                  });
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 18.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Time and Day orientation greeting (Open typography hero)
                        const OrientationHeader(patientName: 'Arthur'),
                        const SizedBox(height: 18),

                        // 2. Safe Zone primary status hero card
                        SafeZoneBanner(info: _currentSafeZoneInfo),
                        const SizedBox(height: 24),

                        // 3. Trusted Support section heading
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 16,
                                color: PatientAppTheme.secondaryText,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'TRUSTED SUPPORT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: PatientAppTheme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Caregiver Quick Connect
                        const CaregiverContactCard(
                          caregiverName: 'Sarah',
                          relationship: 'Daughter',
                          phoneNumber: '(555) 234-5678',
                        ),
                        const SizedBox(height: 14),

                        // Familiar Voice reassuring message
                        const FamiliarVoiceCard(),
                        const SizedBox(height: 26),

                        // 4. Grounded Emergency Help Zone
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626)
                                    .withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emergency_outlined,
                                    color: PatientAppTheme.helpRed,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'EMERGENCY ASSISTANCE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: PatientAppTheme.helpRed,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Press below at any time if you feel lost or need immediate help.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: PatientAppTheme.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 18),
                              EmergencySosButton(
                                onTriggered: () {
                                  // Also notify or log state
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Demo status simulator panel for previewing different safe zone states
            if (widget.isDevMode && _showSimulator) _buildSimulatorBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PatientAppTheme.cardBackground,
        border: const Border(
          top: BorderSide(color: PatientAppTheme.borders, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🧪 Live Status Simulator',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: PatientAppTheme.primaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showSimulator = false),
                    child: const Icon(Icons.close,
                        size: 18, color: PatientAppTheme.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Inside Home', SafeZoneStatus.inside,
                        'Home (Maple Street)'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'Outside Zone', SafeZoneStatus.outside, null),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'Locating GPS', SafeZoneStatus.locating, null),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'Location Paused', SafeZoneStatus.unavailable, null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Signal Delayed', SafeZoneStatus.stale,
                        'Home (Maple Street)'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, SafeZoneStatus status, String? zoneName) {
    final isSelected = _currentSafeZoneInfo.effectiveStatus == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? PatientAppTheme.primaryBlue
              : PatientAppTheme.primaryText,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFEFF6FF),
      backgroundColor: Colors.white,
      side: BorderSide(
        color:
            isSelected ? PatientAppTheme.primaryBlue : PatientAppTheme.borders,
      ),
      onSelected: (_) => _setStatus(status, zoneName),
    );
  }
}
