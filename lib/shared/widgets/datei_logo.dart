import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_theme.dart';

/// Provisional geometric mark: a "D" built from a straight stem and a
/// quarter-arc bowl, with a gold dot marking "a point in time".
/// Final icon directions are explored in Phase 2.
class DateiLogo extends StatelessWidget {
  const DateiLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Datei',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final bg = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.26));
    canvas.drawRRect(bg, Paint()..color = BrandColors.primaryOlive);

    final stroke = Paint()
      ..color = BrandColors.warmCream
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.11
      ..strokeCap = StrokeCap.round;

    final left = s * 0.30;
    final top = s * 0.26;
    final bottom = s * 0.74;
    final h = bottom - top;
    // Stem
    canvas.drawLine(Offset(left, top), Offset(left, bottom), stroke);
    // Bowl: top bar, arc, bottom bar
    final bowlRect = Rect.fromLTWH(left + h * 0.05, top, h, h);
    final path = Path()
      ..moveTo(left, top)
      ..lineTo(bowlRect.center.dx, top)
      ..arcTo(Rect.fromCircle(center: bowlRect.center, radius: h / 2), -math.pi / 2, math.pi, false)
      ..lineTo(left, bottom);
    canvas.drawPath(path, stroke);

    // Gold time marker
    canvas.drawCircle(
      Offset(bowlRect.center.dx - h * 0.02, bowlRect.center.dy),
      s * 0.07,
      Paint()..color = BrandColors.softGold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
