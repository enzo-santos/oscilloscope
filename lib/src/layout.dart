import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/axis_provider.dart';
import 'package:oscilloscope/src/trace_provider.dart';

class OscilloscopeLayout extends StatelessWidget {
  final TraceProvider provider;
  final Widget? xAxis;
  final Widget? yAxis;
  final Widget plot;

  const OscilloscopeLayout({
    Key? key,
    required this.provider,
    required this.plot,
    this.xAxis,
    this.yAxis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget? xAxis = this.xAxis;
    final Widget? yAxis = this.yAxis;
    return CustomMultiChildLayout(
      delegate: _OscilloscopeLayoutDelegate(
          provider.xAxisProvider, provider.yAxisProvider),
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

enum _OscilloscopeLayoutType { xAxis, yAxis, plot }

class _OscilloscopeLayoutDelegate extends MultiChildLayoutDelegate {
  final AxisProvider xProvider;
  final AxisProvider yProvider;

  _OscilloscopeLayoutDelegate(this.xProvider, this.yProvider);

  @override
  void performLayout(Size size) {
    final double xAxisHeight = xProvider.fromSize(size);
    final double yAxisWidth = yProvider.fromSize(size);
    final bool hasXAxis = hasChild(_OscilloscopeLayoutType.xAxis);
    final bool hasYAxis = hasChild(_OscilloscopeLayoutType.yAxis);

    final Size xAxisSize = hasXAxis
        ? layoutChild(
            _OscilloscopeLayoutType.xAxis,
            BoxConstraints.tightFor(
                width: size.width - yAxisWidth, height: xAxisHeight))
        : Size.zero;

    final Size yAxisSize = hasYAxis
        ? layoutChild(
            _OscilloscopeLayoutType.yAxis,
            BoxConstraints.tightFor(
                width: yAxisWidth, height: size.height - xAxisHeight))
        : Size.zero;

    layoutChild(
      _OscilloscopeLayoutType.plot,
      BoxConstraints.tightFor(
          width: size.width - yAxisWidth, height: size.height - xAxisHeight),
    );

    if (hasYAxis) positionChild(_OscilloscopeLayoutType.yAxis, Offset.zero);
    if (hasXAxis)
      positionChild(_OscilloscopeLayoutType.xAxis,
          Offset(yAxisSize.width, size.height - xAxisSize.height));

    positionChild(_OscilloscopeLayoutType.plot, Offset(yAxisSize.width, 0));
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => true;
}
