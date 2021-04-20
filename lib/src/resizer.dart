import 'dart:math';

import 'common.dart';

abstract class Resizer {
  const Resizer();

  bool get shouldLockAxis;

  Range onNewValue(Range oldRange, double newValue);
}

abstract class YResizer extends Resizer {
  const YResizer();

  factory YResizer.fixed(double min, double max) => _FixedYResizer(min, max);

  factory YResizer.global() => const _GlobalYResizer();
}

class _FixedYResizer extends YResizer {
  final double min;
  final double max;

  Range get _range => Range(min, max);

  @override
  bool get shouldLockAxis => true;

  const _FixedYResizer(this.min, this.max);

  @override
  Range onNewValue(Range oldRange, double newValue) =>
      oldRange != _range ? _range : oldRange;
}

class _GlobalYResizer extends YResizer {
  const _GlobalYResizer();

  @override
  bool get shouldLockAxis => false;

  @override
  Range onNewValue(Range oldRange, double newValue) => oldRange == null
      ? Range(newValue, newValue)
      : Range(min(oldRange.min, newValue), max(oldRange.max, newValue));
}

abstract class XResizer extends Resizer {
  factory XResizer.fixed(double min, double max) => _FixedXResizer(min, max);

  factory XResizer.global() => const _GlobalXResizer();

  factory XResizer.local() => const _LocalXResizer();

  const XResizer();
}

class _FixedXResizer extends XResizer {
  final double min;
  final double max;

  Range get _range => Range(min, max);

  @override
  bool get shouldLockAxis => true;

  const _FixedXResizer(this.min, this.max);

  @override
  Range onNewValue(Range oldRange, double newValue) =>
      oldRange != _range ? _range : oldRange;
}

class _GlobalXResizer extends XResizer {
  const _GlobalXResizer();

  @override
  bool get shouldLockAxis => false;

  @override
  Range onNewValue(Range oldRange, double newValue) => oldRange == null
      ? Range(newValue, newValue)
      : Range(min(oldRange.min, newValue), max(oldRange.max, newValue));
}

class _LocalXResizer extends XResizer {
  const _LocalXResizer();

  @override
  bool get shouldLockAxis => false;

  @override
  Range onNewValue(Range oldRange, double newValue) {
    final RangeLimit limit = oldRange.contains(newValue);
    switch (limit) {
      case RangeLimit.inside:
        return oldRange;
      case RangeLimit.under:
        return oldRange.shifted(newValue - oldRange.min);
      case RangeLimit.over:
        return oldRange.shifted(newValue - oldRange.max);
      default:
        throw StateError("invalid limit");
    }
  }
}
