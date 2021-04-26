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
  final RealTimeTraceProvider sineController = RealTimeTraceProvider(
    initialViewport: Viewport(Range(0, 5), Range(-1, 1)),
    xResizer: XResizer.local(),
    yResizer: YResizer.fixed(-1, 1),
    xAxisProvider: AxisProvider.relative(0.05,
        numTicks: 5, onLabel: (v) => v.toStringAsFixed(2)),
    yAxisProvider: AxisProvider.relative(0.05,
        numTicks: 3, onLabel: (v) => v.toInt().toString()),
  );
  final RealTimeTraceProvider cosineController = RealTimeTraceProvider(
    initialViewport: Viewport(Range(0, 5), Range(-1, 1)),
    xResizer: XResizer.local(),
    yResizer: YResizer.fixed(-1, 1),
    xAxisProvider: AxisProvider.relative(0.05,
        numTicks: 5, onLabel: (v) => v.toStringAsFixed(2)),
    yAxisProvider: AxisProvider.relative(0.05,
        numTicks: 3, onLabel: (v) => v.toInt().toString()),
  );

  double radians = 0.0;
  Timer? _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  void _generateTrace(Timer t) {
    // generate our  values
    final double sv = sin((radians * pi));
    final double cv = cos((radians * pi));

    // Add to the growing dataset
    setState(() {
      sineController.add(radians, sv);
      cosineController.add(radians, cv);
    });

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
  static final List<Point> _trace =
      List.generate(30, (i) => i + _random.nextInt(2))
          .map((x) => Point(x.toDouble(), _random.nextDouble()))
          .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    // Create A Scope Display for Sine
    Oscilloscope scopeOne = Oscilloscope(
      sineController,
      margin: EdgeInsets.all(20.0),
      backgroundColor: Colors.white,
      yOriginStyle: TraceStyle(thickness: 0.5, color: Colors.orange),
      traceStyle: TraceStyle(thickness: 1.0, color: Colors.green),
    );

    // Create A Scope Display for Cosine
    Oscilloscope scopeTwo = Oscilloscope(
      cosineController,
      margin: EdgeInsets.all(20.0),
      backgroundColor: Colors.white,
      yOriginStyle: null,
      traceStyle: TraceStyle(thickness: 3.0, color: Colors.yellow),
      backgroundTraces: [
        PlotSeries(_trace, TraceStyle(thickness: 2.0, color: Colors.red)),
      ],
    );

    // Generate the Scaffold
    return Scaffold(
      appBar: AppBar(title: Text("OscilloScope Demo")),
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: scopeOne),
          Expanded(flex: 1, child: scopeTwo),
        ],
      ),
    );
  }
}
