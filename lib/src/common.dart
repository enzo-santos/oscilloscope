class Viewport {
  final Range x;
  final Range y;

  const Viewport(this.x, this.y);

  Viewport copy({Range? x, Range? y}) => Viewport(x ?? this.x, y ?? this.y);

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

class Dimension {
  final Range from;
  final Range to;

  const Dimension(this.from, this.to);

  double scale(double value) {
    if (from.length == 0) return to.min;
    return (((value - from.min) * to.length) / from.length) + to.min;
  }
}

enum RangeLimit { under, inside, over }

class Range {
  final double min;
  final double max;

  const Range(this.min, this.max);

  const Range.fromSize(double size) : this(0, size);

  double get length => max - min;

  Dimension combine(Range other) => Dimension(this, other);

  RangeLimit contains(double value) {
    if (value < min) return RangeLimit.under;
    if (value > max) return RangeLimit.over;
    return RangeLimit.inside;
  }

  Range copy({double? min, double? max}) =>
      Range(min ?? this.min, max ?? this.max);

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

  @override
  String toString() {
    return 'Range{min: $min, max: $max}';
  }
}

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);
}
