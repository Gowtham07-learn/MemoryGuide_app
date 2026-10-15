import 'dart:ui';
import 'package:flutter/material.dart';

/// Design tokens and primitives for the MemoryGuide Caregiver Liquid Glass Design System.
class LiquidGlassTheme {
  // Specular & Frost Opacities
  static const double standardBlur = 18.0;
  static const double intenseBlur = 24.0;
  static const double subtleBlur = 10.0;

  static const double cardRadius = 24.0;
  static const double buttonRadius = 16.0;
  static const double pillRadius = 30.0;

  // Frosted Glass Fill Colors
  static const Color surfaceFill = Color(0xE0FFFFFF);
  static const Color surfaceFillSubtle = Color(0xC2FFFFFF);
  static const Color surfaceFillProminent = Color(0xF5FFFFFF);
  static const Color surfaceFillDark = Color(0xCC111827);

  // Specular Border Colors
  static const Color specularBorderLight = Color(0x7FFFFFFF);
  static const Color specularBorderMid = Color(0x38FFFFFF);
  static const Color specularBorderDark = Color(0x1A111827);

  // Brand Accents
  static const Color forest = Color(0xFF174D43);
  static const Color forestLight = Color(0xFF286B5D);
  static const Color mint = Color(0xFFE7F3EC);
  static const Color ink = Color(0xFF1D2C27);
  static const Color muted = Color(0xFF78847E);

  // Ambient Drop Shadows
  static const List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x1F174D43),
      blurRadius: 26,
      spreadRadius: 2,
      offset: Offset(0, 8),
    ),
  ];
}

/// Atmospheric ambient background tailored for the Caregiver experience:
/// rich slate canvas with diffuse emerald/sage and electric teal blooms.
class GlassAtmosphere extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? primaryGlow;
  final Color? secondaryGlow;

  const GlassAtmosphere({
    super.key,
    required this.child,
    this.isDark = false,
    this.primaryGlow,
    this.secondaryGlow,
  });

  @override
  Widget build(BuildContext context) {
    final glow1 = primaryGlow ??
        (isDark ? const Color(0x28064E3B) : const Color(0x26174D43));
    final glow2 = secondaryGlow ??
        (isDark ? const Color(0x1F0F766E) : const Color(0x2034D399));

    return Stack(
      children: [
        // 1. Base gradient canvas
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0F172A),
                        Color(0xFF0A0F1D),
                        Color(0xFF060913),
                      ]
                    : const [
                        Color(0xFFF9FAFB),
                        Color(0xFFF0F4F2),
                        Color(0xFFE5EDE8),
                      ],
              ),
            ),
          ),
        ),

        // 2. Diffused Top-Left Emerald Bloom
        Positioned(
          top: -100,
          left: -70,
          child: IgnorePointer(
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [glow1, glow1.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
        ),

        // 3. Diffused Center-Right Teal Bloom
        Positioned(
          top: 260,
          right: -90,
          child: IgnorePointer(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [glow2, glow2.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
        ),

        // 4. Content layer
        child,
      ],
    );
  }
}

/// Core Liquid Glass surface with BackdropFilter blur, semi-transparency,
/// continuous rounded corners, and subtle specular highlight.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? customBorder;
  final List<BoxShadow>? shadows;
  final bool hasSheen;

  const GlassSurface({
    super.key,
    required this.child,
    this.blur = LiquidGlassTheme.standardBlur,
    this.borderRadius = LiquidGlassTheme.cardRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.customBorder,
    this.shadows,
    this.hasSheen = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadii = BorderRadius.circular(borderRadius);
    final fill = backgroundColor ?? LiquidGlassTheme.surfaceFill;
    final shadowList = shadows ?? LiquidGlassTheme.ambientShadow;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: borderRadii,
        border: customBorder ??
            Border.all(
              color: LiquidGlassTheme.specularBorderLight,
              width: 1.2,
            ),
        gradient: hasSheen
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.42),
                  Colors.white.withValues(alpha: 0.06),
                ],
                stops: const [0.0, 0.75],
              )
            : null,
      ),
      child: child,
    );

    content = ClipRRect(
      borderRadius: borderRadii,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadii,
        boxShadow: shadowList,
      ),
      child: content,
    );
  }
}

/// Interactive Glass Card with micro-tactile scale feedback.
class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.blur = LiquidGlassTheme.standardBlur,
    this.borderRadius = LiquidGlassTheme.cardRadius,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.backgroundColor,
    this.border,
    this.shadows,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget surface = GlassSurface(
      blur: widget.blur,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      margin: widget.margin,
      backgroundColor: widget.backgroundColor,
      customBorder: widget.border,
      shadows: widget.shadows,
      child: widget.child,
    );

    if (widget.onTap == null) return surface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: (disableAnimations || !_isPressed) ? 1.0 : 0.985,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: surface,
      ),
    );
  }
}

/// Tactile Glass Button with active state and specular highlight edge.
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? foregroundColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.foregroundColor,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = LiquidGlassTheme.buttonRadius,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final btnColor = widget.color ?? LiquidGlassTheme.forest;
    final fgColor = widget.foregroundColor ?? Colors.white;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: (disableAnimations || !_isPressed) ? 1.0 : 0.965,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isEnabled ? btnColor : btnColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: btnColor.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.20),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fgColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: fgColor),
                        const SizedBox(width: 8),
                      ],
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: fgColor,
                          letterSpacing: -0.2,
                        ),
                        child: widget.child,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Compact Glass Icon Button.
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? iconColor;
  final String? tooltip;
  final bool isCircle;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconSize = 22,
    this.color,
    this.iconColor,
    this.tooltip,
    this.isCircle = false,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isEnabled = widget.onPressed != null;
    final fill = widget.color ?? Colors.white.withValues(alpha: 0.75);
    final iconCol = widget.iconColor ?? LiquidGlassTheme.forest;

    Widget btn = GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: (disableAnimations || !_isPressed) ? 1.0 : 0.92,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: fill,
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle ? null : BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: isEnabled ? iconCol : iconCol.withValues(alpha: 0.35),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}

/// Refined status badge / pill rendered in translucent glass.
class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? backgroundColor;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LiquidGlassTheme.pillRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
