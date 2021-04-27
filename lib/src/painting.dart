import 'dart:ui';

import 'package:flutter/painting.dart';

import 'common.dart';

/// Defines the data and the style of a trace.
class PlotSeries {
  /// The list of points that compose a trace.
  final List<Point> data;

  /// The plotter of a trace.
  final Plotter plotter;

  /// Creates a plot series.
  const PlotSeries(this.data, this.plotter);
}

/// Defines how a trace will be plotted.
class TraceStyle {
  /// The thickness of the plotted trace.
  final double thickness;

  /// The color of the plotted trace.
  final Color color;

  /// Creates a trace style.
  const TraceStyle({required this.thickness, required this.color});

  /// The paint of this trace.
  Paint get paint => Paint()
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = thickness
    ..color = color
    ..style = PaintingStyle.stroke;
}

/// Defines how to plot a trace.
abstract class Plotter {
  /// The style of the trace to be plotted by this plotter.
  final TraceStyle style;

  const Plotter(this.style);

  static List<Point> _scale(List<Point> data, Dimension xDim, Dimension yDim) =>
      data.map((p) => Point(xDim.scale(p.x), yDim.reverseScale(p.y))).toList();

  void plot(Canvas canvas, List<Point> data, Dimension xDim, Dimension yDim);
}

class LinePlotter extends Plotter {
  const LinePlotter({required TraceStyle style}) : super(style);

  @override
  void plot(Canvas canvas, List<Point> data, Dimension xDim, Dimension yDim) {
    if (data.isEmpty) return;

    final List<Point> points = Plotter._scale(data, xDim, yDim);

    final Path trace = Path();

    final Point point = points.first;
    trace.moveTo(point.x, point.y);
    for (Point point in points) trace.lineTo(point.x, point.y);
    canvas.drawPath(trace, style.paint);
  }
}

class ScatterPlotter extends Plotter {
  const ScatterPlotter({required TraceStyle style}) : super(style);

  @override
  void plot(Canvas canvas, List<Point> data, Dimension xDim, Dimension yDim) {
    if (data.isEmpty) return;

    final List<Point> points = Plotter._scale(data, xDim, yDim);

    canvas.drawPoints(
      PointMode.points,
      points.map((point) => Offset(point.x, point.y)).toList(),
      style.paint..strokeCap = StrokeCap.round,
    );
  }
}

class FillBetweenPlotter extends Plotter {
  final double upper;
  final double lower;

  const FillBetweenPlotter(
      {required TraceStyle style, required this.upper, required this.lower})
      : super(style);

  @override
  void plot(Canvas canvas, List<Point> data, Dimension xDim, Dimension yDim) {
    if (data.isEmpty) return;

    final Path trace = Path();
    Point point = data.first;
    trace.moveTo(xDim.scale(point.x), yDim.reverseScale(point.y));

    for (int i = 0; i < data.length - 1; i++) {
      final Point current = data[i];
      final Point next = data[i + 1];

      canvas.drawPath(
        Path()
          ..addPolygon(
            [
              Offset(
                  xDim.scale(current.x), yDim.reverseScale(current.y + upper)),
              Offset(
                  xDim.scale(current.x), yDim.reverseScale(current.y - lower)),
              Offset(xDim.scale(next.x), yDim.reverseScale(next.y - lower)),
              Offset(xDim.scale(next.x), yDim.reverseScale(next.y + upper)),
            ],
            false,
          ),
        style.paint..style = PaintingStyle.fill,
      );
      trace.lineTo(xDim.scale(current.x), yDim.reverseScale(current.y));
    }

    point = data.last;
    trace.lineTo(xDim.scale(point.x), yDim.reverseScale(point.y));
    canvas.drawPath(trace, style.paint);
  }
}

class MarkerPlotter extends ScatterPlotter {
  const MarkerPlotter({required TraceStyle style}) : super(style: style);

  @override
  void plot(Canvas canvas, List<Point> data, Dimension xDim, Dimension yDim) {
    if (data.isEmpty) return;
    super.plot(canvas, [data.last], xDim, yDim);
  }
}
