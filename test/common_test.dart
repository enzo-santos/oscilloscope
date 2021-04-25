import 'package:flutter_test/flutter_test.dart';
import 'package:oscilloscope/src/common.dart';

void main() {
  group("Series", () {
    // Each point in this series follows the pattern Point(i, 10 - i).
    // Therefore, we'll be able to create a point using only its x-value.
    const Series series = Series([
      Point(0, 10),
      Point(1, 9),
      Point(2, 8),
      Point(3, 7),
      Point(4, 6),
      Point(5, 5),
      Point(6, 4),
      Point(7, 3),
      Point(8, 2),
      Point(9, 1),
      Point(10, 0),
    ]);

    group("locateFloor", () {
      test("On empty series, return null", () {
        const Series series = Series();
        expect(series.floor(-20), null);
        expect(series.floor(0), null);
        expect(series.floor(20), null);
      });
      test("On input present, return its respective point", () {
        for (double x in series.horizontal) {
          expect(series.floor(x), Point(x, 10 - x));
        }
      });
      test("On input not present and input > x-minimum, return first point with x-value less than input", () {
        for (double x in series.horizontal) {
          expect(series.floor(x + 0.3), Point(x, 10 - x));
          expect(series.floor(x + 0.5), Point(x, 10 - x));
          expect(series.floor(x + 0.7), Point(x, 10 - x));
        }
      });
      test("On input not present and input < x-minimum, return null", () {
        expect(series.floor(series.first.x - 1), null);
        expect(series.floor(series.first.x - 10), null);
      });
    });
    group("locateCeil", () {
      test("On empty series, return null", () {
        const Series series = Series();
        expect(series.ceil(-20), null);
        expect(series.ceil(0), null);
        expect(series.ceil(20), null);
      });
      test("On input present, return its respective point", () {
        for (double x in series.horizontal) {
          expect(series.ceil(x), Point(x, 10 - x));
        }
      });
      test("On input not present and input < x-maximum, return first point with x-value greater than input", () {
        for (double x in series.horizontal) {
          expect(series.ceil(x - 0.3), Point(x, 10 - x));
          expect(series.ceil(x - 0.5), Point(x, 10 - x));
          expect(series.ceil(x - 0.7), Point(x, 10 - x));
        }
      });
      test("On input not present and input > x-maximum, return null", () {
        expect(series.ceil(series.last.x + 1), null);
        expect(series.ceil(series.last.x + 10), null);
      });
    });
    group("estimate", () {
      // Since we'll have to interpolate, we'll create a series that represents
      // a linear curve, but with some of its points missing. In this way, we
      // can predict the missing values.
      const Series series = Series([
        Point(0, 10),
        Point(2, 8),
        Point(4, 6),
        Point(6, 4),
        Point(8, 2),
        Point(10, 0),
      ]);
      test("On input present, return its respective point", () {
        for (double x in series.horizontal) {
          expect(series.estimate(x), Point(x, 10 - x));
        }
      });
      test("On input not present and x-minimum < input < x-maximum, return the interpolation", () {
        // Our goal is to generate x-values that are not present in [series].
        // Therefore, we can return the interspersed x-values of [series] (i.e.
        // if the x-values of a series are [1, 3, 5, 7, 9], its interspersed
        // values are [2, 4, 6, 8] - note that in this example, neither 0 nor 10
        // is included). A way to generate this values is deleting the first
        // element from the x-values of a series and subtracting one from the
        // remaining values. We'll use this approach below.
        for (double x in series.horizontal.skip(1).map((v) => v - 1)) {
          expect(series.estimate(x), Point(x, 10 - x));
        }
      });
      test("On input not present and input < x-minimum, return null", () {
        expect(series.estimate(series.first.x - 1), null);
        expect(series.estimate(series.first.x - 10), null);
      });
      test("On input not present and x-maximum < input, return null", () {
        expect(series.estimate(series.last.x + 1), null);
        expect(series.estimate(series.last.x + 10), null);
      });
    });
    group("fromXRange", () {
      const Series series = Series([
        Point(0, 10),
        Point(2, 8),
        Point(4, 6),
        Point(6, 4),
        Point(8, 2),
        Point(10, 0),
      ]);
      final List<double> xs = series.horizontal.toList();
      test("Left-inclusive and right-inclusive range", () {
        for (int i = 0; i < xs.length; i++) {
          for (int j = i + 1; j < xs.length; j++) {
            expect(
              series.enclose(Range(xs[i], xs[j])),
              xs.sublist(i, j + 1).map((x) => Point(x, 10 - x)).toList(),
            );
          }
        }
      });
      test("Left-exclusive and right-inclusive range", () {
        for (int i = 1; i < xs.length; i++) {
          for (int j = i + 1; j < xs.length; j++) {
            expect(
              series.enclose(Range(xs[i] - 1, xs[j])),
              (xs.sublist(i, j + 1)..insert(0, xs[i] - 1))
                  .map((x) => Point(x, 10 - x))
                  .toList(),
            );
          }
        }
      });
      test("Left-inclusive and right-exclusive range", () {
        for (int i = 0; i < xs.length - 1; i++) {
          for (int j = i + 1; j < xs.length - 1; j++) {
            expect(
              series.enclose(Range(xs[i], xs[j] + 1)),
              (xs.sublist(i, j + 1)..add(xs[j] + 1))
                  .map((x) => Point(x, 10 - x))
                  .toList(),
            );
          }
        }
      });
      test("Left-exclusive and right-exclusive range", () {
        for (int i = 1; i < xs.length - 1; i++) {
          for (int j = i + 1; j < xs.length - 1; j++) {
            expect(
              series.enclose(Range(xs[i] - 1, xs[j] + 1)),
              (xs.sublist(i, j + 1)
                    ..insert(0, xs[i] - 1)
                    ..add(xs[j] + 1))
                  .map((x) => Point(x, 10 - x))
                  .toList(),
            );
          }
        }
      });
    });
  });
}
