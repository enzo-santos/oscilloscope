import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/axis_provider.dart';
import 'package:oscilloscope/src/trace_provider.dart';
import 'package:oscilloscope/src/utils.dart';

abstract class AxisPainter extends CustomPainter {
  static final Paint _paint = Paint()..color = Colors.black;

  final TraceProvider traceProvider;
  final AxisProvider axisProvider;

  const AxisPainter(this.traceProvider, this.axisProvider);

  void _drawXLine(Canvas canvas, double y,
          {required double from, required double to}) =>
      canvas.drawLine(Offset(from, y), Offset(to, y), _paint);

  void _drawYLine(Canvas canvas, double x,
          {required double from, required double to}) =>
      canvas.drawLine(Offset(x, from), Offset(x, to), _paint);

  Range get range;

  Resizer get resizer;

  Size onCalculateTickSize(Size size);

  void onPaintBaseline(Canvas canvas, Size tickSize);

  Offset onPaintTick(Canvas canvas, Size tickSize, Size textSize, double value);

  @override
  void paint(Canvas canvas, Size size) {
    final Size tickSize = onCalculateTickSize(size);
    onPaintBaseline(canvas, tickSize);

    final Range range = this.range;

    final List<double> ticks;
    final List<double>? currentTicks = axisProvider.currentTicks;
    if (currentTicks == null) {
      ticks = linSpace(
        range.min,
        range.max,
        num: axisProvider.numTicks,
        endpoint: resizer.shouldLockAxis,
      ).toList();

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

class XAxisPainter extends AxisPainter {
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

class YAxisPainter extends AxisPainter {
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
