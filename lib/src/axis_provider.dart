import 'package:flutter/painting.dart';

abstract class AxisProvider {
  final int numTicks;
  final String Function(double)? _onLabel;

  const AxisProvider({
    this.numTicks = 5,
    String Function(double)? onLabel,
  }) : _onLabel = onLabel;

  double fromSize(Size size);

  String onLabel(double value) {
    final String Function(double)? action = _onLabel;
    return action == null ? value.toString() : action(value);
  }
}

class RelativeAxisProvider extends AxisProvider {
  final double percentage;

  const RelativeAxisProvider(
    this.percentage, {
    int numTicks = 5,
    String Function(double)? onLabel,
  })  : assert(0 < percentage && percentage <= 1),
        super(numTicks: numTicks, onLabel: onLabel);

  @override
  double fromSize(Size size) => size.longestSide * percentage;
}

class AbsoluteAxisProvider extends AxisProvider {
  final double size;

  const AbsoluteAxisProvider(
    this.size, {
    int numTicks = 5,
    String Function(double)? onLabel,
  }) : super(numTicks: numTicks, onLabel: onLabel);

  @override
  double fromSize(Size size) => this.size;
}
