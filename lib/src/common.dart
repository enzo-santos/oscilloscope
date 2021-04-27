import 'package:oscilloscope/src/utils.dart';

/// Represents a series of points.
class Series {
  /// The data backed by this series.
  ///
  /// Since this class uses binary search on its horizontal values to improve
  /// performance, each point should have its x-value lesser or equal to the
  /// next or it may occur undefined behaviour.
  final List<Point> _data;

  /// Creates a series using a list of points.
  ///
  /// If no [data] is passed, the created series will be empty.
  const Series([List<Point>? data]) : this._data = data ?? const [];

  /// Returns the x-values of this series.
  Iterable<double> get horizontal => _data.map((point) => point.x);

  /// Returns the y-values of this series.
  Iterable<double> get vertical => _data.map((point) => point.y);

  /// Returns the first point of this series.
  ///
  /// The x-value of this point is the x-minimum of this series.
  Point get first => _data.first;

  /// Returns the last point of this series.
  ///
  /// The x-value of this point is the x-maximum of this series.
  Point get last => _data.last;

  /// Calculates the point that contains the greatest x-value less than or equal to [x].
  ///
  /// If there is a point whose x-value is equal to [x], this point is returned.
  /// If this series is empty or [x] < x-minimum, null is returned.
  ///
  /// ```dart
  /// final Series series = Series([
  ///   Point(1.0, 2.0),
  ///   Point(3.0, 6.0),
  ///   Point(5.0, 10.0),
  /// ]);
  /// print(series.floor(0.0)); // null
  /// print(series.floor(1.0)); // Point(1.0, 2.0)
  /// print(series.floor(2.0)); // Point(1.0, 2.0)
  /// print(series.floor(3.0)); // Point(3.0, 6.0)
  /// print(series.floor(4.0)); // Point(3.0, 6.0)
  /// print(series.floor(6.0)); // Point(5.0, 10.0)
  /// ```
  Point? floor(double x) {
    if (_data.isEmpty) return null;
    if (x < _data.first.x) return null;
    final BinarySearchResult result =
        binarySearch<Point>(_data, x, cmp: (point) => point.x);

    switch (result.type) {
      case BinarySearchResultType.found:
        return (result as dynamic).current.value;
      case BinarySearchResultType.notFound:
        return (result as dynamic).previous.value;
    }
  }

  /// Calculates the point that contains the least x-value greater than or equal to [x].
  ///
  /// If there is a point whose x-value is equal to [x], this point is returned.
  /// If this series is empty or [x] > x-maximum, null is returned.
  ///
  /// ```dart
  /// final Series series = Series([
  ///   Point(1.0, 2.0),
  ///   Point(3.0, 6.0),
  ///   Point(5.0, 10.0),
  /// ]);
  /// print(series.ceil(0.0)); // Point(1.0, 2.0)
  /// print(series.ceil(1.0)); // Point(1.0, 2.0)
  /// print(series.ceil(2.0)); // Point(3.0, 6.0)
  /// print(series.ceil(3.0)); // Point(3.0, 6.0)
  /// print(series.ceil(4.0)); // Point(5.0, 10.0)
  /// print(series.ceil(6.0)); // null
  /// ```
  Point? ceil(double x) {
    if (_data.isEmpty) return null;
    if (x > _data.last.x) return null;
    final BinarySearchResult result =
        binarySearch<Point>(_data, x, cmp: (point) => point.x);

    switch (result.type) {
      case BinarySearchResultType.found:
        return (result as dynamic).current.value;
      case BinarySearchResultType.notFound:
        return (result as dynamic).next.value;
    }
  }

  /// Estimates an point based on a intermediate x-value.
  ///
  /// An intermediate x-value is a value such that no point in this series
  /// contains this value as x-value. This uses a simple interpolation to find
  /// the y-value of a given x-value that is not present in this series.
  ///
  /// If [x] < x-minimum or x-maximum < [x], there is no way to estimate this
  /// intermediate point and null is returned.
  ///
  /// ```dart
  /// final Series series = Series([
  ///   Point(1.0, 2.0),
  ///   Point(3.0, 6.0),
  ///   Point(5.0, 10.0),
  /// ]);
  /// print(series.estimate(0.0)); // null
  /// print(series.estimate(1.0)); // Point(1.0, 2.0)
  /// print(series.estimate(2.0)); // Point(2.0, 4.0)
  /// print(series.estimate(3.0)); // Point(3.0, 6.0)
  /// print(series.estimate(4.0)); // Point(4.0, 8.0)
  /// print(series.estimate(6.0)); // null
  /// ```
  Point? estimate(double x) {
    final Point? p0 = floor(x);
    final Point? p1 = ceil(x);
    if (p0 == null || p1 == null) return null;
    if (p0.x == p1.x) return p0;
    return Point(x, p0.y + (x - p0.x) * (p1.y - p0.y) / (p1.x - p0.x));
  }

  /// Creates a list of points that covers from the start to the end of a [range].
  ///
  /// - If [range] minimum is lesser than x-minimum, the first element of the
  /// returned list is x-minimum.
  /// - If [range] minimum is between x-minimum and x-maximum, the first element
  /// of the returned list is the interpolation of this series at x = range minimum.
  /// - If [range] maximum is between x-minimum and  x-maximum, the last element
  /// of the returned list is the interpolation of this series at x = range maximum.
  /// - If x-maximum is lesser than [range] maximum, the last element of the
  /// returned list is x-maximum.
  ///
  /// ```dart
  /// final Series series = Series([
  ///   Point(1.0, 2.0),
  ///   Point(3.0, 6.0),
  ///   Point(5.0, 10.0),
  /// ]);
  /// print(series.enclose(Range(1.0, 5.0));
  /// // [(1, 2), (3, 6), (5, 10)]
  /// print(series.enclose(Range(2.0, 5.0));
  /// // [(2, 4), (3, 6), (5, 10)]
  /// print(series.enclose(Range(1.0, 4.0));
  /// // [(1, 2), (3, 6), (4, 8)]
  /// print(series.enclose(Range(0.0, 6.0));
  /// // [(1, 2), (3, 6), (5, 10)]
  /// ```
  List<Point> enclose(Range range) {
    if (range.max < _data.first.x) return [];
    if (range.min > _data.last.x) return [];

    // Find the index of the first point that is inside range
    BinarySearchResult result;
    result = binarySearch<Point>(_data, range.min, cmp: (point) => point.x);
    final int i0;
    switch (result.type) {
      case BinarySearchResultType.found:
        i0 = (result as dynamic).current.index;
        break;
      case BinarySearchResultType.notFound:
        i0 = (result as dynamic).next.index;
        break;
    }

    // Find the index of the last point that is inside range
    result = binarySearch<Point>(_data, range.max, cmp: (point) => point.x);
    final int i1;
    switch (result.type) {
      case BinarySearchResultType.found:
        i1 = (result as dynamic).current.index;
        break;
      case BinarySearchResultType.notFound:
        i1 = (result as dynamic).previous.index;
        break;
    }

    // Defines all the points that are inside range
    final List<Point> points = _data.sublist(i0, i1 + 1);

    // If the first/last point inside range does not match with the start/end of
    // range, make an interpolation to find out the remaining points
    Point? point;
    if (points.isEmpty || range.min != points.first.x) {
      point = estimate(range.min);
      if (point != null) points.insert(0, point);
    }
    if (points.isEmpty || points.last.x != range.max) {
      point = estimate(range.max);
      if (point != null) points.add(point);
    }
    return points;
  }

  /// Returns how many points are inside this series.
  int get size => _data.length;
}

/// Represents a viewport.
class Viewport {
  /// The x-bounds of this viewport.
  final Range x;

  /// The y-bounds of this viewport.
  final Range y;

  /// Creates a viewport.
  const Viewport(this.x, this.y);

  /// Copy this range using a new configuration, if given.
  Viewport copy({Range? x, Range? y}) => Viewport(x ?? this.x, y ?? this.y);

  /// Returns if this viewport contains a point.
  bool contains(Point point) =>
      x.contains(point.x) == RangeLimit.inside &&
      y.contains(point.y) == RangeLimit.inside;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Viewport &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// Defines how a value should be scaled.
class Dimension {
  /// The origin range.
  final Range from;

  /// The target range.
  final Range to;

  /// Creates a dimension.
  const Dimension(this.from, this.to);

  /// Scales a value from a origin range to a target range.
  ///
  /// The same proportion will be used for mapping the origin to the target,
  /// i.e. if [value] is equal to the maximum of the origin range, the returned
  /// value will be the maximum of the target range.
  double scale(double value) {
    if (from.length == 0) return to.min;
    return (((value - from.min) * to.length) / from.length) + to.min;
  }

  /// Scales a value from a origin range to a reversed target range.
  ///
  /// If a point is being plotted in the vertical axis (where the plotting
  /// orientation is bottom-top instead of top-bottom), this scaling is
  /// preferred.
  double reverseScale(double value) => scale(-value);
}

/// Defines the position of a value relative to a range.
enum RangeLimit { under, inside, over }

/// Represents the bounds of a range of values.
class Range {
  /// The minimum value of this range.
  final double min;

  /// The maximum value of this range.
  final double max;

  /// Creates a range.
  const Range(this.min, this.max);

  /// Creates a range based on some [size].
  ///
  /// The minimum value of this range will be 0 and the maximum will be [size].
  const Range.fromSize(double size) : this(0, size);

  /// The length of this range.
  double get length => (max - min).abs();

  /// This range with [max] and [min] reversed.
  Range reversed() => Range(max, min);

  /// Combines this range with another [range] for scaling purposes.
  Dimension combine(Range range) => Dimension(this, range);

  /// Checks the position of a [value] relative to this range.
  RangeLimit contains(double value) {
    if (value < min) return RangeLimit.under;
    if (value > max) return RangeLimit.over;
    return RangeLimit.inside;
  }

  /// Copy this range using a new configuration, if given.
  Range copy({double? min, double? max}) =>
      Range(min ?? this.min, max ?? this.max);

  /// Shifts this range [value] units.
  ///
  /// If [value] is positive, this range will be shifted to the right. If it's
  /// negative, it will be shifted to the left.
  Range shifted(double value) => Range(min + value, max + value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Range &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => min.hashCode ^ max.hashCode;
}

/// Represents a point.
class Point {
  /// The x-value of this point.
  final double x;

  /// The y-value of this point.
  final double y;

  /// Creates a point.
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }
}
