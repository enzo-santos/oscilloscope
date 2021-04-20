import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/trace_provider.dart';

/// A Custom Painter used to generate the trace line from the supplied dataset
class TracePainter extends CustomPainter {
  final TraceProvider provider;
  final Color traceColor;
  final Color yAxisColor;
  final bool showYAxis;
  final double strokeWidth;

  final Paint _tracePaint;
  final Paint _axisPaint;

  TracePainter(this.provider,
      {required this.showYAxis,
      required this.yAxisColor,
      required this.strokeWidth,
      required this.traceColor})
      : _axisPaint = Paint()
          ..strokeWidth = 1.0
          ..color = yAxisColor,
        _tracePaint = Paint()
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = strokeWidth
          ..color = traceColor
          ..style = PaintingStyle.stroke;

  Path _drawPath(Size size, List<Point> data) {
    final Viewport viewport = provider.viewport;
    final Dimension xDim = viewport.x.combine(Range.fromSize(size.width));
    final Dimension yDim = viewport.y.combine(Range.fromSize(size.height));

    final Path trace = Path();

    final Point point = data.first;
    trace.moveTo(xDim.scale(point.x), yDim.scale(point.y));

    for (Point point in data)
      trace.lineTo(xDim.scale(point.x), yDim.scale(point.y));

    return trace;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // only start plot if dataset has data
    if (provider.values.length == 0) return;

    Path path = _drawPath(size, provider.values);
    canvas.drawPath(path, _tracePaint);

    // if yAxis required draw it here
    if (showYAxis) {
      final Viewport viewport = provider.viewport;
      final Dimension yDim = viewport.y.combine(Range.fromSize(size.height));
      final double yOrigin = yDim.scale(0);
      final Offset yStart = Offset(0, yOrigin);
      final Offset yEnd = Offset(size.width, yOrigin);
      canvas.drawLine(yStart, yEnd, _axisPaint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
