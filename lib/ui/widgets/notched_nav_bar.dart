import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Notched bottom navigation bar.
///
/// The bar is built from two fully static layers plus one animated mask:
///
///  - A "revealed" layer (bottom): for every item, a fixed-size circle
///    in the bar's highlight color with that item's icon inside, drawn
///    once, at a fixed position. This never animates.
///  - A "flat" layer (top): the ordinary dark bar with every item's
///    icon drawn in its plain, un-highlighted style — also drawn once,
///    at the same fixed positions as the revealed layer. This never
///    animates either.
///  - A notch: a hole cut out of the flat layer (via [Path] boolean
///    difference, not an approximated curve) that exposes whatever is
///    behind it on the revealed layer. This is the only thing that
///    animates. Because both layers place every icon at the exact same
///    coordinates, opening or closing the hole never causes an icon to
///    move or jump — it only changes which of the two fixed-position
///    icons is currently visible.
///
/// On a tab change, two notches are open at once: the destination
/// grows from nothing while the origin — after a short delay, so the
/// two don't move in lockstep — shrinks back down and closes.
class NotchedNavBar extends StatefulWidget {
  const NotchedNavBar({
    required this.items,
    required this.currentIndex,
    super.key,
    this.onTap,
  });

  static const double barHeight = 76.0;

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  State<NotchedNavBar> createState() => _NotchedNavBarState();
}

class _NotchedNavBarState extends State<NotchedNavBar>
    with SingleTickerProviderStateMixin {
  // ---- Layout constants -------------------------------------------------
  static const double iconSize = 26;
  static const double bubbleRadius = 24;
  static const double notchRadius = 28; // > bubbleRadius: the difference
  // (4px here) is the constant gap between the revealed bubble and the
  // edge of the notch that exposes it.
  static const double labelZoneHeight = 20;

  // The notch drops from y = 0 down to at most `notchRadius`, so the
  // icon needs at least that much headroom above it; a little extra
  // below keeps the bar from feeling cramped once the notch fully
  // closes again.
  static const double iconCenterY = notchRadius;
  static const double belowIconPad = notchRadius;
  static const double iconRowHeight = iconCenterY + belowIconPad;

  // ---- Animation timing ---------------------------------------------
  static const Duration transitionDuration = Durations.long1;
  static const Curve dropCurve = Curves.easeOutCubic;

  // The destination notch grows across the whole transition...
  static const Interval _toWindow = Interval(0, 1, curve: dropCurve);
  // ...the origin notch doesn't start closing until a beat later, so
  // there's a window where both are open together.
  static const Interval _fromWindow = Interval(0.2, 1, curve: dropCurve);
  // Labels fade on their own, slightly faster timeline than the notches.
  static const Interval _toLabelWindow = Interval(0.1, 1, curve: Curves.easeIn);
  static const Interval _fromLabelWindow = Interval(0, 0.5);
  // ---------------------------------------------------------------------

  late final AnimationController _controller;
  int _fromIndex = 0;
  int _toIndex = 0;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
    _toIndex = widget.currentIndex;
    _controller = AnimationController(vsync: this, duration: transitionDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _fromIndex = _toIndex);
        }
      });
  }

  @override
  void didUpdateWidget(covariant NotchedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        _fromIndex = _toIndex;
        _toIndex = widget.currentIndex;
      });
      _controller
        ..stop()
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isTransitioning => _fromIndex != _toIndex;

  // --- Animation progress --------------------------------------------
  //
  // Each side (to/from) has exactly one progress value; radius and
  // depth are both derived from it so the two never drift apart.

  double get _toProgress {
    if (!_isTransitioning) return 1;
    return _toWindow.transform(_controller.value).clamp(0.0, 1.0);
  }

  double get _toFraction => _toProgress;
  double get _toDepth => iconCenterY * _toProgress;

  /// How far the origin notch has closed: 0 = still fully open,
  /// 1 = fully closed. Idle (no transition) counts as fully closed.
  double get _fromClosedAmount {
    if (!_isTransitioning) return 1;
    return _fromWindow.transform(_controller.value).clamp(0.0, 1.0);
  }

  double get _fromFraction => _isTransitioning ? 1.0 - _fromClosedAmount : 0.0;
  double get _fromDepth =>
      _isTransitioning ? iconCenterY * (1.0 - _fromClosedAmount) : 0.0;

  double _labelOpacity({required bool isTo}) {
    if (!_isTransitioning) return isTo ? 1.0 : 0.0;
    final window = isTo ? _toLabelWindow : _fromLabelWindow;
    final value = window.transform(_controller.value).clamp(0.0, 1.0);
    return isTo ? value : 1.0 - value;
  }

  static double _slotCenterX(double width, int count, int i) =>
      (width / count) * (i + 0.5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.highlightColor;
    final barColor =
        theme.navigationBarTheme.backgroundColor ??
        theme.scaffoldBackgroundColor;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final totalHeight = iconRowHeight + labelZoneHeight + bottomPad;
    final n = widget.items.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: barColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final centers = [
              for (var i = 0; i < n; i++) _slotCenterX(width, n, i),
            ];

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final activeIndices = <int>{
                  _toIndex,
                  if (_isTransitioning) _fromIndex,
                };

                final notches = <_Notch>[
                  for (final index in activeIndices)
                    _Notch(
                      centerX: centers[index],
                      radius:
                          notchRadius *
                          (index == _toIndex ? _toFraction : _fromFraction),
                      depth: index == _toIndex ? _toDepth : _fromDepth,
                    ),
                ];

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Revealed layer — static: bubble + own icon, per item.
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      height: iconRowHeight,
                      child: Stack(
                        children: [
                          for (var i = 0; i < n; i++)
                            Positioned(
                              left: centers[i] - bubbleRadius,
                              top: iconCenterY - bubbleRadius,
                              width: bubbleRadius * 2,
                              height: bubbleRadius * 2,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: highlight,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: iconSize,
                                    height: iconSize,
                                    child: FittedBox(
                                      child: IconTheme.merge(
                                        data: IconThemeData(
                                          color: barColor,
                                          size: iconSize,
                                        ),
                                        child: widget.items[i].icon,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 2. Flat layer — static: dark bar + plain icons,
                    // masked by the one thing that animates: the notch.
                    // Spans the full bar height (not just the icon row)
                    // so its fill and the label-zone background are one
                    // continuous paint with no seam between them.
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _FlatBarPainter(
                          notches: notches,
                          barColor: barColor,
                        ),
                        child: Stack(
                          children: [
                            for (var i = 0; i < n; i++)
                              Positioned(
                                left: centers[i] - iconSize / 2,
                                top: iconCenterY - iconSize / 2,
                                width: iconSize,
                                height: iconSize,
                                child: Opacity(
                                  opacity: 0.7,
                                  child: FittedBox(
                                    child: IconTheme.merge(
                                      data: const IconThemeData(
                                        color: Colors.white,
                                        size: iconSize,
                                      ),
                                      child: widget.items[i].icon,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Labels — fade independently of the notch itself.
                    for (final index in activeIndices)
                      Positioned(
                        left: centers[index] - 60,
                        width: 120,
                        top: iconRowHeight,
                        height: labelZoneHeight,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: _labelOpacity(isTo: index == _toIndex),
                            child: Center(
                              child: Text(
                                widget.items[index].label ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 4. Tap targets, one per slot, full bar height.
                    Positioned.fill(
                      child: Row(
                        children: List.generate(
                          n,
                          (i) => Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onTap?.call(i),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

@immutable
class _Notch {
  const _Notch({
    required this.centerX,
    required this.radius,
    required this.depth,
  });

  final double centerX;
  final double radius;
  final double depth;
}

/// Paints the flat bar's dark fill, with a hole cut out of it for each
/// entry in [notches] via real [Path] boolean difference — not a
/// sampled curve — so overlapping notches merge exactly the way two
/// overlapping discs merge.
class _FlatBarPainter extends CustomPainter {
  const _FlatBarPainter({required this.notches, required this.barColor});

  final List<_Notch> notches;
  final Color barColor;

  @override
  void paint(Canvas canvas, Size size) {
    var barPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final notch in notches) {
      if (notch.radius <= 0 || notch.depth <= 0) continue;
      barPath = Path.combine(
        PathOperation.difference,
        barPath,
        _notchCutout(notch),
      );
    }

    canvas.drawPath(barPath, Paint()..color = barColor);
  }

  /// Builds one notch's cutout silhouette: a horizontal capsule (a band
  /// with its corners filled in by two ellipses) unioned with a
  /// vertical piece that rounds the bottom off — a rect-plus-semicircle
  /// once the notch is deeper than it is wide, or a single squashed
  /// ellipse while it's still shallower than that. The two-piece split
  /// keeps the top edges vertically tangent at every depth, including
  /// very shallow ones where a plain arc would look pinched.
  Path _notchCutout(_Notch notch) {
    final centerX = notch.centerX;
    final r = notch.radius;
    final depth = notch.depth;

    final bandHeight = depth;
    final band = Rect.fromLTWH(centerX - 2 * r, 0, r * 4, bandHeight);
    final leftCap = Path()
      ..addOval(Rect.fromLTWH(centerX - 3 * r, 0, 2 * r, 2 * bandHeight));
    final rightCap = Path()
      ..addOval(Rect.fromLTWH(centerX + r, 0, 2 * r, 2 * bandHeight));

    var horizontalPiece = Path.combine(
      PathOperation.difference,
      Path()..addRect(band),
      leftCap,
    );
    horizontalPiece = Path.combine(
      PathOperation.difference,
      horizontalPiece,
      rightCap,
    );

    final straightHeight = depth - r;
    final Path verticalPiece;
    if (straightHeight > 0) {
      // Deep notch: a straight-sided rect capped with a bottom semicircle.
      final rectPart = Rect.fromLTWH(centerX - r, 0, 2 * r, straightHeight);
      final circlePart = Rect.fromLTWH(
        centerX - r,
        straightHeight,
        2 * r,
        2 * r,
      );
      verticalPiece = Path.combine(
        PathOperation.union,
        Path()..addRect(rectPart),
        Path()..addArc(circlePart, pi, pi), // bottom half only
      );
    } else {
      // Shallow notch: a single ellipse, squashed to the current depth.
      verticalPiece = Path()
        ..addOval(Rect.fromLTWH(centerX - r, 0, 2 * r, 2 * depth));
    }

    return Path.combine(PathOperation.union, horizontalPiece, verticalPiece);
  }

  @override
  bool shouldRepaint(covariant _FlatBarPainter oldDelegate) {
    if (oldDelegate.barColor != barColor) return true;
    if (oldDelegate.notches.length != notches.length) return true;
    for (var i = 0; i < notches.length; i++) {
      final a = oldDelegate.notches[i];
      final b = notches[i];
      if ((a.centerX - b.centerX).abs() > 1e-4 ||
          (a.radius - b.radius).abs() > 1e-4 ||
          (a.depth - b.depth).abs() > 1e-4) {
        return true;
      }
    }
    return false;
  }
}
