import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/painting.dart';
import 'package:oscilloscope/src/trace_provider.dart';

/// A painter used to draw the plot from a trace provider.
class TracePainter extends CustomPainter {
  final TraceProvider provider;

  final TraceStyle traceStyle;
  final TraceStyle? yOriginStyle;
  final List<PlotSeries> backgroundTraces;

  /// Creates a trace painter.
  ///
  /// [traceStyle] defines the style of the main trace. If [yOriginStyle] is
  /// not null, a horizontal line will be plotted at y = 0 using the provided
  /// style.
  const TracePainter(this.provider,
      {this.yOriginStyle,
      this.traceStyle = const TraceStyle(thickness: 1.0, color: Colors.black),
      this.backgroundTraces = const []});

  Path? _drawPath(Size size, List<Point> data) {
    if (data.isEmpty) return null;

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
    // Only start plotting if the provider has data
    if (provider.values.length == 0) return;
    final Viewport viewport = provider.viewport;

    // Draw the main path
    final Path? path = _drawPath(size, provider.values);
    if (path != null) canvas.drawPath(path, traceStyle.paint);

    // Draw the y-origin trace, if required
    final TraceStyle? yOriginStyle = this.yOriginStyle;
    if (yOriginStyle != null) {
      final Dimension yDim = viewport.y.combine(Range.fromSize(size.height));
      final double yOrigin = yDim.scale(0);
      final Offset yStart = Offset(0, yOrigin);
      final Offset yEnd = Offset(size.width, yOrigin);
      canvas.drawLine(yStart, yEnd, yOriginStyle.paint);
    }

    // Draw any background traces
    backgroundTraces.forEach((trace) {
      final List<Point> data = Series(trace.data).enclose(viewport.x);
      final Path? path = _drawPath(size, data);
      if (path != null) canvas.drawPath(path, trace.style.paint);
    });
  }

  @override
  bool shouldRepaint(_) => true;
}
