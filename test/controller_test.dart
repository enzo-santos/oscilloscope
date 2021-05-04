import 'package:flutter_test/flutter_test.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:oscilloscope/src/trace_provider.dart';

void main() {
  test("Initial viewport parameter should be its attribute", () {
    final RealTimeTraceProvider controller = RealTimeTraceProvider(
      xResizer: XResizer.global(),
      yResizer: YResizer.global(),
      initialViewport: Viewport(Range(0, 10), Range(-1, 1)),
    );

    expect(controller.viewport, Viewport(Range(0, 10), Range(-1, 1)));
  });
  test("Global resizer should keep viewport when all points are inside", () {
    const Viewport viewport = Viewport(Range(0, 10), Range(-1, 1));
    final RealTimeTraceProvider controller = RealTimeTraceProvider(
      initialViewport: viewport,
      xResizer: XResizer.global(),
      yResizer: YResizer.global(),
    );

    controller.add(0, -1);
    expect(controller.viewport, viewport);
    controller.add(5, 0);
    expect(controller.viewport, viewport);
    controller.add(10, 1);
    expect(controller.viewport, viewport);
    expect(controller.values.length, 3);
  });
  group("Global resizer should change viewport on overflow", () {
    const Viewport viewport = Viewport(Range(0, 10), Range(-1, 1));
    late RealTimeTraceProvider controller;
    setUp(() {
      controller = RealTimeTraceProvider(
        initialViewport: viewport,
        xResizer: XResizer.global(),
        yResizer: YResizer.global(),
      );
    });

    test("Horizontal underflow", () {
      controller.add(-15, 0);
      expect(controller.viewport, viewport.copy(x: Range(-15, 10)));
    });
    test("Horizontal overflow", () {
      controller.add(15, 0);
      expect(controller.viewport, viewport.copy(x: Range(0, 15)));
    });
    test("Vertical underflow", () {
      controller.add(0, -5);
      expect(controller.viewport, viewport.copy(y: Range(-5, 1)));
    });
    test("Vertical overflow", () {
      controller.add(0, 5);
      expect(controller.viewport, viewport.copy(y: Range(-1, 5)));
    });
    test("Total overflow", () {
      controller.add(-15, 5);
      expect(controller.viewport, Viewport(Range(-15, 10), Range(-1, 5)));
    });
  });
  test("Fixed resizer should keep viewport until a point is added", () {
    const Viewport viewport = Viewport(Range(0, 10), Range(-1, 1));
    final RealTimeTraceProvider controller = RealTimeTraceProvider(
      initialViewport: viewport,
      xResizer: XResizer.fixed(-5, 5),
      yResizer: YResizer.fixed(-3, 3),
    );
    expect(controller.viewport, viewport);
    controller.add(0, 0);
    expect(controller.viewport, Viewport(Range(-5, 5), Range(-3, 3)));
  });
  test("Fixed resizer should keep viewport on default", () {
    final RealTimeTraceProvider controller = RealTimeTraceProvider(
      initialViewport: Viewport(Range(0, 10), Range(-1, 1)),
      xResizer: XResizer.fixed(-5, 5),
      yResizer: YResizer.fixed(-5, 5),
    );

    controller.add(0, -5);
    expect(controller.viewport, Viewport(Range(-5, 5), Range(-5, 5)));
    controller.add(3, -3);
    expect(controller.viewport, Viewport(Range(-5, 5), Range(-5, 5)));
    controller.add(5, 0);
    expect(controller.viewport, Viewport(Range(-5, 5), Range(-5, 5)));
    expect(controller.values.length, 3);
  });
  group("Fixed resizer should delete points on overflow", () {
    late RealTimeTraceProvider controller;
    setUp(() {
      controller = RealTimeTraceProvider(
        initialViewport: Viewport(Range(0, 10), Range(-1, 1)),
        xResizer: XResizer.fixed(-5, 5),
        yResizer: YResizer.fixed(-3, 3),
      );
    });
    tearDown(() {
      expect(controller.viewport, Viewport(Range(-5, 5), Range(-3, 3)));
      expect(controller.values.length, 0);
    });

    test("Left-outside point", () => controller.add(-10, 0));
    test("Right-outside point", () => controller.add(10, 0));
    test("Top-outside point", () => controller.add(0, 5));
    test("Bottom-outside point", () => controller.add(0, -5));
    test("All-outside point", () => controller.add(-5, 10));
  });
  test("Local horizontal resizer should change viewport on overflow", () {
    final RealTimeTraceProvider controller = RealTimeTraceProvider(
      initialViewport: Viewport(Range(0, 5), Range(-1, 1)),
      xResizer: XResizer.local(),
      yResizer: YResizer.fixed(-5, 5),
    );
    controller.add(0, -1);
    controller.add(1, 0);
    controller.add(2, 1);
    controller.add(3, 0);
    controller.add(4, -1);
    expect(controller.viewport, Viewport(Range(0, 5), Range(-5, 5)));
    controller.add(5, 0);
    expect(controller.viewport, Viewport(Range(0, 5), Range(-5, 5)));
    controller.add(6, 1);
    expect(controller.viewport, Viewport(Range(1, 6), Range(-5, 5)));
    controller.add(7, 0);
    expect(controller.viewport, Viewport(Range(2, 7), Range(-5, 5)));
    controller.add(10, -1);
    expect(controller.viewport, Viewport(Range(5, 10), Range(-5, 5)));
  });
  test("Local horizontal resizer should delete old points on overflow", () {
    final RealTimeTraceProvider controller = RealTimeTraceProvider(
      initialViewport: Viewport(Range(0, 5), Range(-1, 1)),
      xResizer: XResizer.local(),
      yResizer: YResizer.fixed(-5, 5),
    );
    controller.add(0, -1);
    controller.add(1, 0);
    controller.add(2, 1);
    controller.add(3, 0);
    controller.add(4, -1);
    expect(controller.viewport, Viewport(Range(0, 5), Range(-5, 5)));
    expect(controller.values.length, 5);
    controller.add(5, 0);
    expect(controller.viewport, Viewport(Range(0, 5), Range(-5, 5)));
    expect(controller.values.length, 6);
    controller.add(6, 1);
    expect(controller.viewport, Viewport(Range(1, 6), Range(-5, 5)));
    expect(controller.values.length, 6);
    controller.add(7, 0);
    expect(controller.viewport, Viewport(Range(2, 7), Range(-5, 5)));
    expect(controller.values.length, 6);
    controller.add(15, -1);
    expect(controller.viewport, Viewport(Range(10, 15), Range(-5, 5)));
    expect(controller.values.length, 1);
  });
}
