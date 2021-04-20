Iterable<double> linSpace(double start, double stop,
    {int num = 50, bool endpoint = false}) sync* {
  if (num == 1) {
    yield stop;
  } else {
    final double step = (stop - start) / (num - (endpoint ? 1 : 0));
    for (int i = 0; i < num; i++) yield start + step * i;
  }
}

int binarySearch<T>(List<T> a, T x,
        {bool floorOnError = true, required num Function(T) cmp}) =>
    _binarySearch(a, x, 0, a.length - 1, floorOnError, cmp);

int _binarySearch<T>(
    List<T> a, T x, int low, int high, bool floorOnError, num Function(T) cmp) {
  if (high >= low) {
    final int mid = (high + low) ~/ 2;

    if (a[mid] == x) return mid;
    if (cmp(a[mid]) > cmp(x))
      return _binarySearch(a, x, low, mid - 1, floorOnError, cmp);
    return _binarySearch(a, x, mid + 1, high, floorOnError, cmp);
  }

  if (floorOnError) return high == -1 ? 0 : high;
  return low;
}
