class IndexedValue<T> {
  final int index;
  final T value;

  IndexedValue.of(List<T> values, int index) : this(index, values[index]);

  const IndexedValue(this.index, this.value);
}

Iterable<double> linSpace(double start, double stop,
    {int num = 50, bool endpoint = false}) sync* {
  if (num == 1) {
    yield stop;
  } else {
    final double step = (stop - start) / (num - (endpoint ? 1 : 0));
    for (int i = 0; i < num; i++) yield start + step * i;
  }
}

enum BinarySearchResultType { found, notFound }

abstract class BinarySearchResult<T> {
  final BinarySearchResultType type;

  const BinarySearchResult(this.type);

  factory BinarySearchResult.found(List<T> values, int index) =>
      _BinarySearchHasFoundResult(IndexedValue.of(values, index));

  factory BinarySearchResult.notFound(List<T> values,
          {int? previous, int? next}) =>
      _BinarySearchHasNotFoundResult(
        previous == null ? null : IndexedValue.of(values, previous),
        next == null ? null : IndexedValue.of(values, next),
      );
}

class _BinarySearchHasFoundResult<T> extends BinarySearchResult<T> {
  final IndexedValue<T> current;

  const _BinarySearchHasFoundResult(this.current)
      : super(BinarySearchResultType.found);
}

class _BinarySearchHasNotFoundResult<T> extends BinarySearchResult<T> {
  final IndexedValue<T>? previous;
  final IndexedValue<T>? next;

  const _BinarySearchHasNotFoundResult(this.previous, this.next)
      : super(BinarySearchResultType.notFound);
}

BinarySearchResult<T> binarySearch<T>(List<T> a, num x,
    {required num Function(T) cmp}) {
  return _binarySearch(a, x, 0, a.length - 1, cmp);
}

BinarySearchResult<T> _binarySearch<T>(
    List<T> a, num x, int low, int high, num Function(T) cmp) {
  if (high >= low) {
    final int mid = (high + low) ~/ 2;

    if (cmp(a[mid]) == x) return BinarySearchResult.found(a, mid);
    if (cmp(a[mid]) > x) return _binarySearch(a, x, low, mid - 1, cmp);
    return _binarySearch(a, x, mid + 1, high, cmp);
  }

  return BinarySearchResult.notFound(
    a,
    previous: high == -1 ? null : high,
    next: low == a.length ? null : low,
  );
}
