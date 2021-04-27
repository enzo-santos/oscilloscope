import 'dart:async';
import 'dart:math';

/// Demo of using the oscilloscope package
///
/// In this demo 2 displays are generated showing the outputs for Sine & Cosine
/// The scope displays will show the data sets  which will fill the yAxis and then the screen display will 'scroll'
import 'package:flutter/material.dart' hide Viewport;
import 'package:oscilloscope/oscilloscope.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Oscilloscope Display Example",
      home: Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  @override
  _ShellState createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final RealTimeTraceProvider cosineController = RealTimeTraceProvider(
    initialViewport: Viewport(Range(0, 5), Range(-1, 1)),
    xResizer: XResizer.local(),
    yResizer: YResizer.fixed(-1, 1),
  );

  double radians = 0.0;
  Timer? _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  void _generateTrace(Timer t) {
    // Add to the controller
    setState(() => cosineController.add(radians, cos(radians * pi)));
    radians += 0.05;
  }

  @override
  initState() {
    super.initState();
    // create our timer to generate test values
    _timer = Timer.periodic(Duration(milliseconds: 60), _generateTrace);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static final Random _random = Random();
  static final List<Point> _trace = List.generate(50, (i) => i * 10)
      .map((x) => Point(x.toDouble(), (_random.nextInt(20) - 10) / 10))
      .toList(growable: false);

  Plotter _getPlotter(String name, TraceStyle style) {
    switch (name) {
      case "line":
        return LinePlotter(style: style);
      case "scatter":
        return ScatterPlotter(style: style);
      case "fill":
        return FillBetweenPlotter(style: style, upper: 0.2, lower: 0.2);
      default:
        throw ArgumentError.value(name, "name");
    }
  }

  // Defines the oscilloscope settings
  String _plotName = "line";
  String _backgroundPlotName = "fill";
  double _margin = 20;
  double _thickness = 3;
  double _backgroundThickness = 2;
  Color _backgroundColor = Colors.white;
  Color _traceColor = Colors.yellow;
  bool _showXAxis = true;
  bool _showYAxis = true;
  List<Point>? _backgroundTrace = _trace;
  Color _backgroundTraceColor = Colors.red.withAlpha(0x44);
  int _numXTicks = 5;
  int _numYTicks = 3;
  int _numXLabel = 2;
  int _numYLabel = 0;

  // Build the oscilloscope using the defined settings
  Widget _buildOscilloscope() {
    return Oscilloscope(
      cosineController,
      margin: EdgeInsets.all(_margin),
      backgroundColor: _backgroundColor,
      showXAxis: _showXAxis,
      showYAxis: _showYAxis,
      yOriginStyle: null,
      xAxisProvider: RelativeAxisProvider(
        0.05,
        numTicks: _numXTicks,
        onLabel: (v) => v.toStringAsFixed(_numXLabel),
      ),
      yAxisProvider: RelativeAxisProvider(
        0.05,
        numTicks: _numYTicks,
        onLabel: (v) => v.toStringAsFixed(_numYLabel),
      ),
      tracePlotter: _getPlotter(
        _plotName,
        TraceStyle(thickness: _thickness, color: _traceColor),
      ),
      backgroundTraces: [
        if (_backgroundTrace != null)
          PlotSeries(
            _backgroundTrace!,
            _getPlotter(
              _backgroundPlotName,
              TraceStyle(
                thickness: _backgroundThickness,
                color: _backgroundTraceColor,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate the Scaffold
    return Scaffold(
      appBar: AppBar(title: Text("OscilloScope Demo")),
      body: Column(
        children: [
          Expanded(child: _buildOscilloscope()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Control panel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _OptionControlTile(
                        title: "Plot",
                        length: 3,
                        labels: ["Line", "Scatter", "Fill between"],
                        onSelected: (i) {
                          setState(() =>
                              _plotName = const ["line", "scatter", "fill"][i]);
                        },
                      ),
                      _ColorControlTile(
                        title: "Color",
                        colors: [Colors.white, Colors.grey, Colors.blueGrey],
                        onSelected: (color) {
                          setState(() => _backgroundColor = color);
                        },
                      ),
                      _ColorControlTile(
                        title: "Trace color",
                        colors: [Colors.red, Colors.green, Colors.yellow],
                        onSelected: (color) {
                          setState(() => _traceColor = color);
                        },
                      ),
                      _NumberControlTile(
                        title: "Margin",
                        value: _margin.toInt(),
                        onDecrease: () {
                          setState(() => _margin = max(0, _margin - 5));
                        },
                        onIncrease: () {
                          setState(() => _margin = min(50, _margin + 5));
                        },
                      ),
                      _NumberControlTile(
                        title: "Thickness",
                        value: _thickness.toInt(),
                        onDecrease: () => setState(() {
                          --_thickness;
                          if (_thickness < 0) _thickness = 0;
                        }),
                        onIncrease: () => setState(() {
                          ++_thickness;
                          if (_thickness > 10) _thickness = 10;
                        }),
                      ),
                      Divider(),
                      _BooleanControlTile(
                        title: "Background trace",
                        value: _backgroundTrace != null,
                        onChanged: (v) {
                          setState(() => _backgroundTrace = v ? _trace : null);
                        },
                      ),
                      _OptionControlTile(
                        title: "Plot",
                        labels: ["Line", "Fill between"],
                        length: 2,
                        onSelected: (i) {
                          setState(() =>
                              _backgroundPlotName = const ["line", "fill"][i]);
                        },
                      ),
                      _ColorControlTile(
                        title: "Trace color",
                        colors: [
                          Colors.purple.withAlpha(0x44),
                          Colors.blue.withAlpha(0x44),
                          Colors.orange.withAlpha(0x44),
                        ],
                        onSelected: (color) {
                          setState(() => _backgroundTraceColor = color);
                        },
                      ),
                      _NumberControlTile(
                        title: "Thickness",
                        value: _backgroundThickness.toInt(),
                        onDecrease: () => setState(() {
                          _backgroundThickness =
                              max(0, _backgroundThickness - 1);
                        }),
                        onIncrease: () => setState(() {
                          _backgroundThickness =
                              min(10, _backgroundThickness + 1);
                        }),
                      ),
                      Divider(),
                      _BooleanControlTile(
                        title: "Horizontal axis",
                        value: _showXAxis,
                        onChanged: (v) => setState(() => _showXAxis = v),
                      ),
                      _NumberControlTile(
                        title: "Ticks",
                        value: _numXTicks.toInt(),
                        onDecrease: () {
                          setState(() => _numXTicks = max(2, _numXTicks - 1));
                        },
                        onIncrease: () {
                          setState(() => _numXTicks = min(5, _numXTicks + 1));
                        },
                      ),
                      _NumberControlTile(
                        title: "Decimals",
                        value: _numXLabel.toInt(),
                        onDecrease: () {
                          setState(() => _numXLabel = max(0, _numXLabel - 1));
                        },
                        onIncrease: () {
                          setState(() => _numXLabel = min(3, _numXLabel + 1));
                        },
                      ),
                      Divider(),
                      _BooleanControlTile(
                        title: "Vertical axis",
                        value: _showYAxis,
                        onChanged: (v) => setState(() => _showYAxis = v),
                      ),
                      _NumberControlTile(
                        title: "Ticks",
                        value: _numYTicks.toInt(),
                        onDecrease: () {
                          setState(() => _numYTicks = max(2, _numYTicks - 1));
                        },
                        onIncrease: () {
                          setState(() => _numYTicks = min(5, _numYTicks + 1));
                        },
                      ),
                      _NumberControlTile(
                        title: "Decimals",
                        value: _numYLabel.toInt(),
                        onDecrease: () {
                          setState(() => _numYLabel = max(0, _numYLabel - 1));
                        },
                        onIncrease: () {
                          setState(() => _numYLabel = min(3, _numYLabel + 1));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _OptionControlTile extends StatelessWidget {
  final String title;
  final int length;
  final List<String>? labels;
  final void Function(int) onSelected;

  const _OptionControlTile(
      {required this.title,
      required this.length,
      required this.onSelected,
      this.labels});

  Widget _buildChild(BuildContext context, int index) {
    final Widget child = MaterialButton(
      color: Theme.of(context).primaryColor,
      child: Text("$index"),
      onPressed: () => onSelected(index),
    );
    final List<String>? labels = this.labels;
    if (labels == null) return child;
    return Tooltip(message: labels[index], child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(title),
          ),
        ),
        for (int i = 0; i < length; i++) _buildChild(context, i)
      ],
    );
  }
}

class _ColorControlTile extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final void Function(Color) onSelected;

  const _ColorControlTile(
      {required this.title, required this.colors, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(title),
          ),
        ),
        for (Color color in colors)
          MaterialButton(color: color, onPressed: () => onSelected(color))
      ],
    );
  }
}

class _NumberControlTile extends StatelessWidget {
  final String title;
  final num value;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _NumberControlTile(
      {required this.title,
      required this.value,
      required this.onIncrease,
      required this.onDecrease});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(title),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_drop_down),
          onPressed: onDecrease,
        ),
        Container(child: Text("$value")),
        IconButton(
          icon: Icon(Icons.arrow_drop_up),
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

class _BooleanControlTile extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const _BooleanControlTile(
      {required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: (value) => onChanged(value ?? false),
    );
  }
}
