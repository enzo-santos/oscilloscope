import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/axis_provider.dart';
import 'package:oscilloscope/src/trace_provider.dart';
import 'package:oscilloscope/src/utils.dart';

/// A painter used to draw the axis of an oscilloscope.
abstract class AxisPainter extends CustomPainter {
  static final Paint _paint = Paint()..color = Colors.black;

  final TraceProvider traceProvider;
  final AxisProvider axisProvider;

  /// Creates an axis painter.
  const AxisPainter(this.traceProvider, this.axisProvider);

  void _drawXLine(Canvas canvas, double y,
          {required double from, required double to}) =>
      canvas.drawLine(Offset(from, y), Offset(to, y), _paint);

  void _drawYLine(Canvas canvas, double x,
          {required double from, required double to}) =>
      canvas.drawLine(Offset(x, from), Offset(x, to), _paint);

  /// The bounds of the axis being plotted.
  Range get range;

  /// The resizer of the axis being plotted.
  Resizer get resizer;

  /// Defines the space where the ticks will be plotted from the total available space.
  Size onCalculateTickSize(Size size);

  /// Draws the line that will contain the ticks on a [canvas].
  ///
  /// [tickSize] is the size returned by [onCalculateTickSize].
  void onPaintBaseline(Canvas canvas, Size tickSize);

  /// Draws each tick on a [canvas].
  ///
  /// [value] is the numeric value this tick is representing. [tickSize] is the
  /// size returned by [onCalculateTickSize] and [textSize] is the size of label
  /// corresponding to this tick.
  Offset onPaintTick(Canvas canvas, Size tickSize, Size textSize, double value);

  @override
  void paint(Canvas canvas, Size size) {
    final Size tickSize = onCalculateTickSize(size);
    onPaintBaseline(canvas, tickSize);

    final Range range = this.range;

    final List<double> ticks;
    final List<double>? currentTicks = axisProvider.currentTicks;
    if (currentTicks == null) {
      ticks = linSpace(range.min, range.max,
              num: axisProvider.numTicks, endpoint: resizer.shouldLockAxis)
          .toList();
      axisProvider.currentTicks = ticks;
    } else {
      ticks = currentTicks;
    }

    for (double tick in ticks) {
      final String label = axisProvider.onLabel(tick);
      final TextPainter labelPainter = TextPainter(
          text: TextSpan(text: label, style: TextStyle(color: Colors.black)),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: size.width);

      final Offset offset = onPaintTick(canvas, tickSize,
          Size(labelPainter.minIntrinsicWidth, labelPainter.height), tick);
      labelPainter.paint(canvas, offset);
    }

    if (ticks.first < range.min) {
      ticks.removeAt(0);
      ticks.add(range.max);
    }
    if (ticks.last > range.max) {
      ticks.removeLast();
      ticks.insert(0, range.min);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// A painter used to draw the horizontal axis of an oscilloscope.
class XAxisPainter extends AxisPainter {
  /// Creates a horizontal axis painter.
  XAxisPainter(TraceProvider traceProvider)
      : super(traceProvider, traceProvider.xAxisProvider);

  @override
  Resizer get resizer => traceProvider.xResizer;

  @override
  Range get range => traceProvider.viewport.x;

  @override
  Size onCalculateTickSize(Size size) => Size(size.width, size.height / 2);

  @override
  void onPaintBaseline(Canvas canvas, Size tickSize) {
    _drawXLine(canvas, tickSize.height / 2, from: 0, to: tickSize.width);
  }

  @override
  Offset onPaintTick(Canvas canvas, Size tickSize, Size textSize, double tick) {
    final double x = ((tick - range.min) / range.length) * tickSize.width;
    _drawYLine(canvas, x, from: 0, to: tickSize.height);
    return Offset(x - textSize.width / 2, textSize.height);
  }
}

/// A painter used to draw the vertical axis of an oscilloscope.
class YAxisPainter extends AxisPainter {
  /// Creates a vertical axis painter.
  YAxisPainter(TraceProvider traceProvider)
      : super(traceProvider, traceProvider.yAxisProvider);

  @override
  Resizer get resizer => traceProvider.yResizer;

  @override
  Range get range => traceProvider.viewport.y;

  @override
  Size onCalculateTickSize(Size size) => Size(size.width / 2, size.height);

  @override
  void onPaintBaseline(Canvas canvas, Size tickSize) {
    _drawYLine(canvas, tickSize.width / 2, from: 0, to: tickSize.height);
  }

  @override
  Offset onPaintTick(Canvas canvas, Size tickSize, Size textSize, double tick) {
    final double y = (1 - (tick - range.min) / range.length) * tickSize.height;
    _drawXLine(canvas, y, from: 0, to: tickSize.width);
    return Offset(-tickSize.width, y - textSize.height / 2);
  }
}
