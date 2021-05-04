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
    final Scaling xScaling = viewport.xScale(Range.fromSize(size.width));
    final Scaling yScaling = viewport.yScale(Range.fromSize(size.height));

    // Draw the main path
    tracePlotter.plot(canvas, provider.values, xScaling, yScaling);

    // Draw the y-origin trace, if required
    final TraceStyle? yOriginStyle = this.yOriginStyle;
    if (yOriginStyle != null) {
      final double yOrigin = yScaling.scale(0);
      final Offset yStart = Offset(0, yOrigin);
      final Offset yEnd = Offset(size.width, yOrigin);
      canvas.drawLine(yStart, yEnd, yOriginStyle.paint);
    }

    // Draw any background traces
    backgroundTraces.forEach((trace) {
      final List<Point> data = Series(trace.data).enclose(viewport.x);
      trace.plotter.plot(canvas, data, xScaling, yScaling);
    });
  }

  @override
  bool shouldRepaint(_) => true;
}
