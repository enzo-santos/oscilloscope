import 'dart:math';

import 'common.dart';

/// Defines how an axis should be resized based on the plotted data.
abstract class Resizer {
  const Resizer();

  /// If the corresponding axis of this resizer is fixed.
  ///
  /// This property should return true if the corresponding axis will not change
  /// its bounds no matter how the data will be displayed on the plot.
  ///
  /// If this property is true, it's expected that [onNewValue] will always
  /// return the same range.
  bool get shouldLockAxis;

  /// Defines the resizing policy of this resizer.
  ///
  /// Defines a new range for this axis based on the [oldRange] every time a
  /// [newValue] added to the plot. If [oldRange] is null, a range is not yet
  /// defined for this axis.
  Range onNewValue(Range? oldRange, double newValue);
}

/// Defines how a vertical axis should resize.
abstract class YResizer extends Resizer {
  const YResizer();

  /// Creates a tight bound resizer.
  ///
  /// This axis will not resize no matter how the data is being plotted.
  /// Therefore, its y-minimum will always be [min] and its y-maximum will
  /// always be [max]. If the y-value of a point being plotted is lesser than
  /// [min] or greater than [max], this point will not be shown.
  factory YResizer.fixed(double min, double max) => _FixedYResizer(min, max);

  /// Creates a loose bound resizer.
  ///
  /// This axis will resize based on the data being plotted. If the y-value of
  /// a point being plotted is lesser/greater than the current y-minimum/
  /// y-maximum, the new y-minimum/y-maximum will be the y-value of this point.
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
  Range onNewValue(Range? oldRange, double newValue) => oldRange ?? _range;
}

class _GlobalYResizer extends YResizer {
  const _GlobalYResizer();

  @override
  bool get shouldLockAxis => false;

  @override
  Range onNewValue(Range? oldRange, double newValue) => oldRange == null
      ? Range(newValue, newValue)
      : Range(min(oldRange.min, newValue), max(oldRange.max, newValue));
}

/// Defines how a horizontal axis should resize.
abstract class XResizer extends Resizer {
  /// Creates a tight bound resizer.
  ///
  /// This axis will not resize no matter how the data is being plotted.
  /// Therefore, its x-minimum will always be [min] and its x-maximum will
  /// always be [max]. If the x-value of a point being plotted is lesser than
  /// [min] or greater than [max], this point will not be shown.
  factory XResizer.fixed(double min, double max) => _FixedXResizer(min, max);

  /// Creates a loose bound resizer.
  ///
  /// This axis will resize based on the data being plotted. If the x-value of
  /// a point being plotted is lesser/greater than the current x-minimum/
  /// x-maximum, the new x-minimum/x-maximum will be the x-value of this point.
  factory XResizer.global() => const _GlobalXResizer();

  /// Creates a moving, fixed bound resizer.
  ///
  /// While this axis will resize based on the data being plotted, this axis
  /// will have a fixed length. If the x-value of a point being plotted if
  /// lesser/greater than the current x-minimum/x-maximum, this axis will shift
  /// to the left/right keeping its length to make sure this point will be
  /// shown, hiding any previous points on the shifted part.
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
  Range onNewValue(Range? oldRange, double newValue) => oldRange ?? _range;
}

class _GlobalXResizer extends XResizer {
  const _GlobalXResizer();

  @override
  bool get shouldLockAxis => false;

  @override
  Range onNewValue(Range? oldRange, double newValue) => oldRange == null
      ? Range(newValue, newValue)
      : Range(min(oldRange.min, newValue), max(oldRange.max, newValue));
}

class _LocalXResizer extends XResizer {
  const _LocalXResizer();

  @override
  bool get shouldLockAxis => false;

  @override
  Range onNewValue(Range? oldRange, double newValue) {
    if (oldRange == null) return Range(0, 0);
    final RangeLimit limit = oldRange.contains(newValue);
    switch (limit) {
      case RangeLimit.inside:
        return oldRange;
      case RangeLimit.under:
        return oldRange.shifted(newValue - oldRange.min);
      case RangeLimit.over:
        return oldRange.shifted(newValue - oldRange.max);
    }
  }
}
