import 'package:material_ui/material_ui.dart';

/// Wraps a nav-bar [icon] with a soft "sonar ping" — a fuzzy ring that
/// grows outward by a centimeter or two and fades away. Intended to
/// nudge attention toward the icon after some out-of-band event (e.g.
/// the selected breathing pattern changed).
///
/// The ping is purely decorative: it paints outside the icon's normal
/// footprint via [OverflowBox], so it never changes the layout size the
/// surrounding nav bar sees. The icon itself is left uncolored so it
/// keeps picking up [BottomNavigationBar]'s selected/unselected
/// [IconTheme], exactly like the plain `Icon` widgets used for the other
/// tabs; the ping ring borrows that same color.
class NavPingIcon extends AnimatedWidget {
  const NavPingIcon({
    required Animation<double> animation,
    required this.icon,
    super.key,
  }) : super(listenable: animation);

  final IconData icon;

  Animation<double> get _progress => listenable as Animation<double>;

  // How far the ping is allowed to grow beyond the icon, in logical
  // pixels. Flutter's logical pixel is defined as 1/96th of an inch, so
  // ~38 logical pixels is roughly one centimeter — this keeps the ping
  // within the "one or two centimeters" it should reach.
  static const double _maxSpread = 56;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = iconTheme.size ?? 24;
    final color = iconTheme.color ?? Theme.of(context).colorScheme.primary;
    final overlaySize = iconSize + _maxSpread * 2;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: OverflowBox(
        maxWidth: overlaySize,
        maxHeight: overlaySize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: CustomPaint(
                size: Size.square(overlaySize),
                painter: _PingPainter(progress: _progress.value, color: color),
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}

class _PingPainter extends CustomPainter {
  _PingPainter({required this.progress, required this.color});

  /// 0 at rest, animates 0 -> 1 for one ping.
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;

    // Ease the growth out (fast start, slow finish) and fade in the
    // second half, so the ring reads as expanding-then-dissolving rather
    // than a hard-edged circle popping in and out.
    final grow = Curves.easeOut.transform(progress);
    final fade = Curves.easeIn.transform(progress);

    final radius = maxRadius * grow;
    final opacity = (1 - fade).clamp(0.0, 1.0);
    if (opacity <= 0 || radius <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _PingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
