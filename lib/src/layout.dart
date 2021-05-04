import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/axis_provider.dart';

/// Defines the layout of an oscilloscope.
///
/// An oscilloscope is composed by three parts: the plot, where the trace will
/// be drawn; the x-axis, where the horizontal ticks will be drawn; and the
/// y-axis, where the vertical ticks will be drawn. Despite the plot being
/// required, each axis is optional and contains information about the current
/// viewport, such as the x-maximum and the y-minimum.
///
/// The y-axis is positioned in the top-left of the screen, with a bottom
/// padding of x-axis height (or zero if the x-axis is disabled). The x-axis is
/// positioned in the bottom-right of the screen, with a left padding of y-axis
/// width (or zero if the y-axis is not defined). The plot is positioned in the
/// top-right of the screen, in the right of y-axis and in the top of x-axis.
///
/// The number of ticks and the label for each axis can be defined using a
/// [AxisProvider].
class OscilloscopeLayout extends StatelessWidget {
  final AxisProvider? xAxisProvider;
  final AxisProvider? yAxisProvider;
  final Widget? xAxis;
  final Widget? yAxis;
  final Widget plot;

  /// Creates the layout of an oscilloscope.
  ///
  /// If the x-axis or the y-axis should be enabled (i.e. is not null), their
  /// corresponding axis provider must be defined.
  const OscilloscopeLayout({
    required this.plot,
    this.xAxisProvider,
    this.yAxisProvider,
    this.xAxis,
    this.yAxis,
  })  : assert(xAxis == null || xAxisProvider != null),
        assert(yAxis == null || yAxisProvider != null);

  @override
  Widget build(BuildContext context) {
    final Widget? xAxis = this.xAxis, yAxis = this.yAxis;
    final bool hasX = xAxis != null, hasY = yAxis != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        final double xHeight =
            (hasX ? xAxisProvider?.fromSize(size) : null) ?? 0;
        final double yWidth =
            (hasY ? yAxisProvider?.fromSize(size) : null) ?? 0;
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (hasY)
                    SizedBox(
                      width: yWidth,
                      height: double.infinity,
                      child: yAxis,
                    ),
                  Expanded(child: SizedBox.expand(child: plot)),
                ],
              ),
            ),
            Row(
              children: [
                if (hasX && hasY) Container(width: yWidth, height: xHeight),
                if (hasX)
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: xHeight,
                      child: xAxis,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
