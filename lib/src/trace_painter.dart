import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/trace_provider.dart';

/// A Custom Painter used to generate the trace line from the supplied dataset
class TracePainter extends CustomPainter {
  final TraceProvider provider;
  final Color traceColor;
  final Color yAxisColor;
  final bool showYOrigin;
  final double strokeWidth;
  final List<Point>? backgroundTrace;

  final Paint _tracePaint;
  final Paint _axisPaint;

  TracePainter(this.provider,
      {required this.showYOrigin,
      required this.yAxisColor,
      required this.strokeWidth,
      required this.traceColor,
      this.backgroundTrace})
      : _axisPaint = Paint()
          ..strokeWidth = 1.0
          ..color = yAxisColor,
        _tracePaint = Paint()
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = strokeWidth
          ..color = traceColor
          ..style = PaintingStyle.stroke;

  Path? _drawPath(Size size, List<Point> data) {
    if (data.isEmpty) return null;

    final Viewport viewport = provider.viewport;
    final Dimension xDim = viewport.x.combine(Range.fromSize(size.width));
    final Dimension yDim = viewport.y.combine(Range.fromSize(size.height));

    final Path trace = Path()..fillType = PathFillType.nonZero;

    final Point point = data.first;
    trace.moveTo(xDim.scale(point.x), yDim.scale(point.y));

    for (Point point in data)
      trace.lineTo(xDim.scale(point.x), yDim.scale(point.y));

    return trace;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Only start plotting if the provider has data
    if (provider.values.length == 0) return;
    final Viewport viewport = provider.viewport;

    Path? path;
    path = _drawPath(size, provider.values);
    if (path != null) canvas.drawPath(path, _tracePaint);

    // if yAxis required draw it here
    if (showYOrigin) {
      final Dimension yDim = viewport.y.combine(Range.fromSize(size.height));
      final double yOrigin = yDim.scale(0);
      final Offset yStart = Offset(0, yOrigin);
      final Offset yEnd = Offset(size.width, yOrigin);
      canvas.drawLine(yStart, yEnd, _axisPaint);
    }

    final List<Point>? backgroundTrace = this.backgroundTrace;
    if (backgroundTrace != null) {
      final List<Point> trace = Series(backgroundTrace).enclose(viewport.x);
      path = _drawPath(size, trace);
      if (path != null)
        canvas.drawPath(
          path,
          _tracePaint..color = Colors.black,
        );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
