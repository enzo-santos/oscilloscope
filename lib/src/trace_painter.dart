import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/painting.dart';
import 'package:oscilloscope/src/trace_provider.dart';

/// A painter used to draw the plot from a trace provider.
class TracePainter extends CustomPainter {
  final TraceProvider provider;

  final Plotter tracePlotter;
  final TraceStyle? yOriginStyle;
  final List<PlotSeries> backgroundTraces;

  /// Creates a trace painter.
  ///
  /// [traceStyle] defines the style of the main trace. If [yOriginStyle] is
  /// not null, a horizontal line will be plotted at y = 0 using the provided
  /// style.
  const TracePainter(this.provider,
      {this.yOriginStyle,
      required this.tracePlotter,
      this.backgroundTraces = const []});

  @override
  void paint(Canvas canvas, Size size) {
    // Only start plotting if the provider has data
    if (provider.values.isEmpty) return;

    final Viewport viewport = provider.viewport;
    final Dimension xDim = viewport.x.combine(Range.fromSize(size.width));
    final Dimension yDim = viewport.y.combine(Range.fromSize(size.height));

    // Draw the main path
    tracePlotter.plot(canvas, provider.values, xDim, yDim);

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
      final Plotter plotter = trace.plotter;
      final List<Point> data = Series(trace.data).enclose(viewport.x);
      plotter.plot(canvas, data, xDim, yDim);
    });
  }

  @override
  bool shouldRepaint(_) => true;
}
