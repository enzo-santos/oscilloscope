import 'package:flutter/painting.dart';

import 'common.dart';

/// Defines the data and the style of a trace.
class PlotSeries {
  /// The list of points that compose a trace.
  final List<Point> data;

  /// The style of a trace.
  final TraceStyle style;

  /// Creates a plot series.
  const PlotSeries(this.data, this.style);
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
