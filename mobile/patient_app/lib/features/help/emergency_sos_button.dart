import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Callback type for triggering the emergency action.
/// Supports both synchronous and asynchronous operations.
typedef SosTriggerCallback = FutureOr<void> Function();

/// High-contrast, large touch-target Emergency SOS button for patients.
///
/// Designed with cognitive accessibility and safety in mind. Prevents accidental
/// repeated submissions, handles loading and error states, and maintains an honest
/// demonstration notice when live alert dispatch services are not connected.
class EmergencySosButton extends StatefulWidget {
  final SosTriggerCallback? onTriggered;

  /// Whether the button operates in demonstration mode.
  ///
  /// Defaults to `true` while the backend authentication and live alert
  /// dispatch services are not integrated into the patient app session.
  final bool isDemoMode;

  const EmergencySosButton({
    super.key,
    this.onTriggered,
    this.isDemoMode = true,
  });

  @override
  State<EmergencySosButton> createState() => _EmergencySosButtonState();
}

class _EmergencySosButtonState extends State<EmergencySosButton> {
  bool _isLoading = false;
  bool _isDispatched = false;
  bool _isPressed = false;

  Future<void> _triggerEmergency() async {
    // Prevent repeated accidental submissions while a request is being processed
    if (_isLoading) return;

    // If already dispatched, re-open the status dialog so the patient can review or reset
    if (_isDispatched) {
      if (mounted) _showSosDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onTriggered != null) {
        final result = widget.onTriggered!();
        if (result is Future) {
          await result;
        }
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isDispatched = true;
      });

      _showSosDialog();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorDialog(error);
    }
  }

  void _showSosDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFDE8E8),
        icon: Icon(
          widget.isDemoMode
              ? Icons.info_outline_rounded
              : Icons.emergency_rounded,
          color: const Color(0xFFC5221F),
          size: 48,
        ),
        title: Text(
          widget.isDemoMode
              ? 'Emergency Help (Demo Mode)'
              : 'Help Request Sent',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF991B1B),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isDemoMode) ...[
              const Text(
                'This application is running in demonstration mode and is not connected to a live alert service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFB91C1C), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No caregiver or emergency services have been notified.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'In an actual emergency, please dial 911 (or local emergency) directly or call your caregiver using the card above.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF6B7280),
                ),
              ),
            ] else ...[
              const Text(
                'Your help request was sent to the server and is awaiting caregiver acknowledgment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        color: Color(0xFFB45309), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waiting for caregiver confirmation. Please stay safe.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF374151),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _isDispatched = false;
              });
              Navigator.of(ctx).pop();
            },
            child: Text(
              widget.isDemoMode
                  ? 'Understood (Reset)'
                  : 'I am Safe Now (Reset)',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(Object error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFEF2F2),
        icon: const Icon(Icons.error_outline_rounded,
            color: Color(0xFFDC2626), size: 48),
        title: const Text(
          'Unable to Send Alert',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF991B1B),
          ),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A problem occurred while processing your emergency request. The alert could not be verified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, height: 1.4, color: Color(0xFF374151)),
            ),
            SizedBox(height: 12),
            Text(
              'If you need immediate assistance, please dial emergency services (911) or contact your caregiver directly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF374151),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      container: true,
      button: true,
      label: _isDispatched
          ? 'Emergency Help Sent. Tap to view status or reset.'
          : 'Emergency SOS button. Tap for emergency help.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: (disableAnimations || !_isPressed) ? 1.0 : 0.96,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: Container(
                height: 170,
                width: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isDispatched
                              ? const Color(0xFF991B1B)
                              : PatientAppTheme.helpRed)
                          .withValues(alpha: _isPressed ? 0.25 : 0.38),
                      blurRadius: _isPressed ? 14 : 24,
                      spreadRadius: _isPressed ? 1 : 2,
                      offset: Offset(0, _isPressed ? 3 : 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDispatched
                        ? const Color(0xFF991B1B)
                        : PatientAppTheme.helpRed,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 0,
                  ),
                  onPressed: _triggerEmergency,
                  child: _isLoading
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.5,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'SENDING...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isDispatched
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.warning_rounded,
                              size: 52,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isDispatched ? 'HELP SENT' : 'CALL HELP',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isDispatched
                ? 'Tap to view status or reset'
                : 'Tap for emergency help',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: PatientAppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
