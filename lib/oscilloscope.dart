// Copyright (c) 2018, Steve Rogers. All rights reserved. Use of this source code
// is governed by an Apache License 2.0 that can be found in the LICENSE file.
library oscilloscope;

import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/src/axis_painter.dart';
import 'package:oscilloscope/src/layout.dart';
import 'package:oscilloscope/src/painting.dart';
import 'package:oscilloscope/src/trace_painter.dart';
import 'package:oscilloscope/src/trace_provider.dart';

export 'package:oscilloscope/src/axis_provider.dart';
export 'package:oscilloscope/src/common.dart';
export 'package:oscilloscope/src/painting.dart';
export 'package:oscilloscope/src/resizer.dart';
export 'package:oscilloscope/src/trace_provider.dart';

/// Defines a customisable oscilloscope that can be used to graph out data.
class Oscilloscope extends StatelessWidget {
  final TraceProvider traceProvider;
  final Color backgroundColor;
  final bool showXAxis;
  final bool showYAxis;
  final TraceStyle traceStyle;
  final TraceStyle? yOriginStyle;
  final EdgeInsetsGeometry margin;
  final List<PlotSeries> backgroundTraces;

  /// Creates an oscilloscope.
  const Oscilloscope(
    this.traceProvider, {
    this.backgroundColor = Colors.black,
    this.margin = const EdgeInsets.all(10.0),
    this.traceStyle = const TraceStyle(thickness: 2.0, color: Colors.black),
    this.yOriginStyle = const TraceStyle(thickness: 0.5, color: Colors.grey),
    this.showXAxis = true,
    this.showYAxis = true,
    this.backgroundTraces = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: margin,
      color: backgroundColor,
      child: OscilloscopeLayout(
        xAxisProvider: traceProvider.xAxisProvider,
        yAxisProvider: traceProvider.yAxisProvider,
        plot: ClipRect(
          child: CustomPaint(
            painter: TracePainter(
              traceProvider,
              traceStyle: traceStyle,
              yOriginStyle: yOriginStyle,
              backgroundTraces: backgroundTraces,
            ),
          ),
        ),
        xAxis: showXAxis
            ? CustomPaint(painter: XAxisPainter(traceProvider))
            : null,
        yAxis: showYAxis
            ? CustomPaint(painter: YAxisPainter(traceProvider))
            : null,
      ),
    );
  }
}
