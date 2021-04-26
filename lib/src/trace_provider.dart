import 'package:oscilloscope/src/axis_provider.dart';
import 'package:oscilloscope/src/resizer.dart';

import 'common.dart';

/// Provides a list of points to be plotted by an oscilloscope.
abstract class TraceProvider {
  final XResizer xResizer;
  final YResizer yResizer;
  final AxisProvider xAxisProvider;
  final AxisProvider yAxisProvider;

  /// Creates a trace provider.
  ///
  /// [xResizer] and [yResizer] represents the resizers of both axes.
  /// [xAxisProvider] and [yAxisProvider] provides the ticks of both axes.
  TraceProvider(
      {required this.xResizer,
      required this.yResizer,
      AxisProvider? xAxisProvider,
      AxisProvider? yAxisProvider})
      : xAxisProvider = xAxisProvider ?? AxisProvider.relative(0.05),
        yAxisProvider = yAxisProvider ?? AxisProvider.relative(0.05);

  /// The data of this provider.
  List<Point> get values;

  /// The viewport based on the current data of this provider.
  Viewport get viewport;
}

/// Provides a on-demand list of points to be plotted by an oscilloscope.
class RealTimeTraceProvider extends TraceProvider {
  /// Callback property called whenever the horizontal axis is resized.
  final void Function()? onXUpdate;

  /// Creates a real-time trace provider.
  RealTimeTraceProvider(
      {Viewport? initialViewport,
      required YResizer yResizer,
      required XResizer xResizer,
      AxisProvider? xAxisProvider,
      AxisProvider? yAxisProvider,
      this.onXUpdate})
      : _viewport = initialViewport ?? Viewport(Range(0, 1), Range(0, 1)),
        super(
            xResizer: xResizer,
            yResizer: yResizer,
            xAxisProvider: xAxisProvider,
            yAxisProvider: yAxisProvider);

  @override
  Viewport get viewport => _viewport;

  @override
  List<Point> get values => _values;

  final List<Point> _values = [];

  Viewport _viewport;

  void add(double x, double y) {
    final Point point = Point(x, y);

    // Monotonically increasing in horizontal axis
    assert(_values.isEmpty || _values.last.x < point.x);

    // Create a new viewport based on the new point
    final Viewport newViewport = _viewport.copy(
        x: xResizer.onNewValue(_viewport.x, point.x),
        y: yResizer.onNewValue(_viewport.y, point.y));

    if (_viewport != newViewport) {
      if (newViewport.x != _viewport.x) onXUpdate?.call();
      _viewport = newViewport;
    }

    // If new point is inside viewport, you can add it
    if (_viewport.contains(point)) _values.add(point);

    // Remove already existing points if they're not inside the horizontal axis.
    // Since points are monotonically increasing in the horizontal axis, this
    // check can be done lazily using the head and the tail points
    final Range xRange = _viewport.x;
    while (_values.isNotEmpty && _values.first.x < xRange.min)
      _values.removeAt(0);
    while (_values.isNotEmpty && _values.last.x > xRange.max)
      _values.removeLast();
  }
}
