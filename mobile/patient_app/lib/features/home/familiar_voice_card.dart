import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reassuring card providing quick access to a recorded voice message
/// from a loved one or primary caregiver to reduce disorientation and distress.
class FamiliarVoiceCard extends StatefulWidget {
  /// Path to a local asset or remote audio URL.
  /// If null or empty, the card indicates that no recording has been configured yet.
  final String? audioSource;

  /// Optional name of the person whose voice is recorded (defaults to 'Caregiver').
  final String? recordedByName;

  /// Optional callback invoked when play is pressed.
  final VoidCallback? onPlayPressed;

  const FamiliarVoiceCard({
    super.key,
    this.audioSource,
    this.recordedByName,
    this.onPlayPressed,
  });

  @override
  State<FamiliarVoiceCard> createState() => _FamiliarVoiceCardState();
}

class _FamiliarVoiceCardState extends State<FamiliarVoiceCard> {
  AudioPlayer? _player;
  bool _isPlaying = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _handlePlay() async {
    widget.onPlayPressed?.call();

    // If no audio recording is configured, honestly notify the patient
    if (widget.audioSource == null || widget.audioSource!.isEmpty) {
      _showNoRecordingDialog();
      return;
    }

    try {
      _player ??= AudioPlayer();

      if (_isPlaying) {
        await _player!.stop();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } else {
        setState(() {
          _isPlaying = true;
        });

        _player!.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        });

        if (widget.audioSource!.startsWith('http://') ||
            widget.audioSource!.startsWith('https://')) {
          await _player!.play(UrlSource(widget.audioSource!));
        } else {
          await _player!.play(AssetSource(widget.audioSource!));
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _showPlaybackErrorDialog();
      }
    }
  }

  void _showNoRecordingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(
          Icons.info_outline_rounded,
          color: Color(0xFF6D28D9),
          size: 44,
        ),
        title: const Text(
          'Voice Message Not Available',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your caregiver has not recorded a familiar voice message yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, height: 1.4, color: Color(0xFF374151)),
            ),
            SizedBox(height: 12),
            Text(
              'When your family adds a recording, you can listen to it here anytime for comforting guidance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, height: 1.3, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showPlaybackErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFDC2626),
          size: 44,
        ),
        title: const Text(
          'Playback Error',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF991B1B),
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Unable to play the voice message. Please check your device audio volume.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF374151)),
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
    return Semantics(
      container: true,
      label:
          'Familiar Voice message card. Listen to a familiar voice message. Tap Play Voice button to listen.',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PatientAppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                _isPlaying ? const Color(0xFFC4B5FD) : PatientAppTheme.borders,
            width: _isPlaying ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPlaying
                  ? PatientAppTheme.voicePurple.withValues(alpha: 0.08)
                  : const Color(0xFF172033).withValues(alpha: 0.04),
              blurRadius: _isPlaying ? 16 : 12,
              offset: const Offset(0, 3),
            ),
          ],
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
                    color: PatientAppTheme.softPurple,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFDDD6FE),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: PatientAppTheme.voicePurple,
                        size: 11,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'COMFORTING VOICE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PatientAppTheme.voicePurple,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _isPlaying ? 'Playing Audio' : 'Recorded Message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _isPlaying ? FontWeight.bold : FontWeight.w500,
                    color: _isPlaying
                        ? PatientAppTheme.voicePurple
                        : PatientAppTheme.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Card content + Play button
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;

                final content = Row(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: PatientAppTheme.softPurple,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDDD6FE),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: PatientAppTheme.voicePurple,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Familiar Voice',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: PatientAppTheme.primaryText,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Listen to a familiar voice message',
                            style: TextStyle(
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

                final playButton = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PatientAppTheme.voicePurple,
                    foregroundColor: Colors.white,
                    elevation: 0.5,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _handlePlay,
                  icon: Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _isPlaying ? 'Stop' : 'Play Voice',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      content,
                      const SizedBox(height: 14),
                      playButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 12),
                    playButton,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
