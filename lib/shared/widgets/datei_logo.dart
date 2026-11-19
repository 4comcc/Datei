import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_theme.dart';

/// Datei mark — direction A "Geometric D" (ADR-036): a solid D (stem + bowl)
/// with a soft-gold point inside, a single moment in time.
///
/// Geometry matches `assets/branding/datei_icon.svg` (1024-unit canvas).
class DateiLogo extends StatelessWidget {
  const DateiLogo({super.key, this.size = 96, this.withBackground = true});

  final double size;

  /// Rounded olive tile behind the mark (app-icon look). Without it the mark is drawn in olive.
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Datei',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _DateiMarkPainter(withBackground: withBackground)),
      ),
    );
  }
}

class _DateiMarkPainter extends CustomPainter {
  const _DateiMarkPainter({required this.withBackground});
  final bool withBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 1024;
    canvas.scale(k);

    if (withBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 1024, 1024), const Radius.circular(230)),
        Paint()..color = BrandColors.primaryOlive,
      );
    }

    // Outer D: stem from x=271 to the bowl, bowl radius 262 centred at (491, 512).
    final d = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(271, 250)
      ..lineTo(491, 250)
      ..arcToPoint(const Offset(491, 774), radius: const Radius.circular(262))
      ..lineTo(271, 774)
      ..close()
      // Counter (inner cut-out), radius 152.
      ..moveTo(381, 360)
      ..lineTo(491, 360)
      ..arcToPoint(const Offset(491, 664), radius: const Radius.circular(152))
      ..lineTo(381, 664)
      ..close();
    canvas.drawPath(d, Paint()..color = withBackground ? BrandColors.warmCream : BrandColors.primaryOlive);

    canvas.drawCircle(const Offset(500, 512), 62, Paint()..color = BrandColors.softGold);
  }

  @override
  bool shouldRepaint(covariant _DateiMarkPainter oldDelegate) => oldDelegate.withBackground != withBackground;
}
