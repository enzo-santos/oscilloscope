// Copyright (c) 2018, Steve Rogers. All rights reserved. Use of this source code
// is governed by an Apache License 2.0 that can be found in the LICENSE file.
library oscilloscope;

import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/src/axis_painter.dart';
import 'package:oscilloscope/src/layout.dart';
import 'package:oscilloscope/src/trace_painter.dart';
import 'package:oscilloscope/src/trace_provider.dart';

export 'package:oscilloscope/src/axis_provider.dart';
export 'package:oscilloscope/src/common.dart';
export 'package:oscilloscope/src/resizer.dart';
export 'package:oscilloscope/src/trace_provider.dart';

/// A widget that defines a customisable Oscilloscope type display that can be used to graph out data
///
/// The [dataSet] arguments MUST be a List<double> -  this is the data that is used by the display to generate a trace
///
/// All other arguments are optional as they have preset values
///
/// [showYOrigin] this will display a line along the yAxisat 0 if the value is set to true (default is false)
/// [yOriginColor] determines the color of the displayed yAxis (default value is Colors.white)
///
/// [yAxisMin] and [yAxisMax] although optional should be set to reflect the data that is supplied in [dataSet]. These values
/// should be set to the min and max values in the supplied [dataSet].
///
/// For example if the max value in the data set is 2.5 and the min is -3.25  then you should set [yAxisMin] = -3.25 and [yAxisMax] = 2.5
/// This allows the oscilloscope display to scale the generated graph correctly.
///
/// You can modify the background color of the oscilloscope with the [backgroundColor] argument and the color of the trace with [traceColor]
///
/// The [margin] argument allows space to be set around the display (this defaults to EdgeInsets.all(10.0) if not specified)
///
/// The [strokeWidth] argument defines how wide to make lines drawn (this defaults to 2.0 if not specified).
class Oscilloscope extends StatelessWidget {
  final TraceProvider traceProvider;
  final Color backgroundColor;
  final Color traceColor;
  final bool showXAxis;
  final bool showYAxis;
  final Color yOriginColor;
  final bool showYOrigin;
  final double strokeWidth;
  final EdgeInsetsGeometry margin;

  const Oscilloscope(
    this.traceProvider, {
    this.traceColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.yOriginColor = Colors.white,
    this.margin = const EdgeInsets.all(10.0),
    this.showYOrigin = false,
    this.strokeWidth = 2.0,
    this.showXAxis = true,
    this.showYAxis = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: margin,
      color: backgroundColor,
      child: OscilloscopeLayout(
        provider: traceProvider,
        plot: ClipRect(
          child: CustomPaint(
            painter: TracePainter(
              traceProvider,
              showYOrigin: showYOrigin,
              yAxisColor: yOriginColor,
              traceColor: traceColor,
              strokeWidth: strokeWidth,
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
