import 'package:flutter/painting.dart';

abstract class AxisProvider {
  final int numTicks;
  final String Function(double)? _onLabel;

  AxisProvider({
    this.numTicks = 5,
    String Function(double)? onLabel,
  }) : _onLabel = onLabel;

  factory AxisProvider.relative(
    double percentage, {
    int numTicks = 5,
    String Function(double)? onLabel,
  }) =>
      _RelativeAxisProvider(percentage, numTicks: numTicks, onLabel: onLabel);

  factory AxisProvider.absolute(
    double value, {
    int numTicks = 5,
    String Function(double)? onLabel,
  }) =>
      _AbsoluteAxisProvider(value, numTicks: numTicks, onLabel: onLabel);

  List<double>? currentTicks;

  double fromSize(Size size);

  String onLabel(double value) {
    final String Function(double)? action = _onLabel;
    return action == null ? value.toString() : action(value);
  }
}

class _RelativeAxisProvider extends AxisProvider {
  final double percentage;

  _RelativeAxisProvider(
    this.percentage, {
    int numTicks = 5,
    String Function(double)? onLabel,
  })  : assert(0 < percentage && percentage <= 1),
        super(numTicks: numTicks, onLabel: onLabel);

  @override
  double fromSize(Size size) => size.longestSide * percentage;
}

class _AbsoluteAxisProvider extends AxisProvider {
  final double size;

  _AbsoluteAxisProvider(
    this.size, {
    int numTicks = 5,
    String Function(double)? onLabel,
  }) : super(numTicks: numTicks, onLabel: onLabel);

  @override
  double fromSize(Size size) => this.size;
}
