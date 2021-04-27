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
    final Widget? xAxis = this.xAxis;
    final Widget? yAxis = this.yAxis;
    return CustomMultiChildLayout(
      delegate: _OscilloscopeLayoutDelegate(xAxisProvider, yAxisProvider),
      children: [
        if (xAxis != null)
          LayoutId(id: _OscilloscopeLayoutType.xAxis, child: xAxis),
        if (yAxis != null)
          LayoutId(id: _OscilloscopeLayoutType.yAxis, child: yAxis),
        LayoutId(id: _OscilloscopeLayoutType.plot, child: plot),
      ],
    );
  }
}

/// Defines the type of each part of an oscilloscope layout.
enum _OscilloscopeLayoutType { xAxis, yAxis, plot }

/// Positions each part of an oscilloscope layout in the screen.
///
/// The y-axis is positioned in the top-left of the screen, with a bottom
/// padding of x-axis height (or zero if the x-axis is disabled). The x-axis is
/// positioned in the bottom-right of the screen, with a left padding of y-axis
/// width (or zero if the y-axis is not defined). The plot is positioned in the
/// top-right of the screen, in the right of y-axis and in the top of x-axis.
class _OscilloscopeLayoutDelegate extends MultiChildLayoutDelegate {
  final AxisProvider? xProvider;
  final AxisProvider? yProvider;

  _OscilloscopeLayoutDelegate(this.xProvider, this.yProvider);

  @override
  void performLayout(Size size) {
    final bool hasX = hasChild(_OscilloscopeLayoutType.xAxis);
    final bool hasY = hasChild(_OscilloscopeLayoutType.yAxis);
    final double xHeight = (hasX ? xProvider?.fromSize(size) : null) ?? 0;
    final double yWidth = (hasY ? yProvider?.fromSize(size) : null) ?? 0;

    final Size xAxisSize = hasX
        ? layoutChild(
            _OscilloscopeLayoutType.xAxis,
            BoxConstraints.tightFor(
                width: size.width - yWidth, height: xHeight))
        : Size.zero;

    final Size yAxisSize = hasY
        ? layoutChild(
            _OscilloscopeLayoutType.yAxis,
            BoxConstraints.tightFor(
                width: yWidth, height: size.height - xHeight))
        : Size.zero;

    layoutChild(
      _OscilloscopeLayoutType.plot,
      BoxConstraints.tightFor(
          width: size.width - yWidth, height: size.height - xHeight),
    );

    if (hasY) positionChild(_OscilloscopeLayoutType.yAxis, Offset.zero);
    if (hasX)
      positionChild(_OscilloscopeLayoutType.xAxis,
          Offset(yAxisSize.width, size.height - xAxisSize.height));

    positionChild(_OscilloscopeLayoutType.plot, Offset(yAxisSize.width, 0));
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => true;
}
