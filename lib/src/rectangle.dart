import 'dart:math';

/// A simple compareTo. This is ~5% faster than the default compareTo because
/// it does not have to handle edge cases with large numbers.
/// See https://github.com/dart-lang/sdk/blob/249895f979d484184f9d0b7a177b413a41726eb7/sdk/lib/_internal/vm/lib/integers.dart#L215
int compareTo(num a, num b) {
  if (b < a) {
    return -1;
  } else if (b > a) {
    return 1;
  }
  return 0;
}

/// Compare two rectangles by height, decending.
int Function(Rectangle a, Rectangle b) compareByHeight =
    (Rectangle a, Rectangle b) => compareTo(a.height, b.height);

/// Compare two rectangles by area, decending.
int Function(Rectangle a, Rectangle b) compareByArea =
    (Rectangle a, Rectangle b) => compareTo(a.area, b.area);

/// Compare two rectangles by width, decending.
int Function(Rectangle a, Rectangle b) compareByWidth =
    (Rectangle a, Rectangle b) => compareTo(a.width, b.width);

/// Compare two rectangles by perimeter, decending. (That is 2*width+height).
int Function(Rectangle a, Rectangle b) compareByPerimeter =
    (Rectangle a, Rectangle b) => compareTo(a.perimeter, b.perimeter);

extension RectangleExt<T extends num> on Rectangle<T> {
  T get area => (width * height) as T;
  T get perimeter => (2 * (width + height)) as T;
}

extension RectangleSplitExt<T extends num> on Rectangle<T> {
  /// Takes [other] and places it into the top left corner of this, splitting
  /// this Rectangle into two. Returns the two new rectangles, the smaller split, and a bigger split.
  /// If other is larger than this this an exception is thrown. If other fits
  /// perfectly then a empty list is returned. If other fits perfect in one dimension
  /// then a single split is returned.
  ///
  /// ![Example diagram](https://github.com/TeamHypersomnia/rectpack2D/raw/master/images/diag01.png)
  (Rectangle<T>?, Rectangle<T>?) split(Rectangle<T> other) {
    // The input is already checked in [pack],
    assert(other.left == 0 && other.top == 0);
    assert(other.area > 0);

    // The free area should always stay positive, and integer.
    assert(area > 0);
    assert(width.roundToDouble() == width);
    assert(height.roundToDouble() == height);

    if (other.width > width || other.height > height) {
      throw Exception("Can't split a smaller rectangle into a larger one");
    }

    if (other.height == height && other.width == width) {
      // ------------------
      // |      Other     |
      // |      /this     |
      // ------------------
      return (null, null); // No space left.
    }

    if (other.height == height) {
      // ------------------
      // |  Other  | ret  |
      // |         |      |
      // ------------------
      return (
        Rectangle(
          (left + other.width) as T,
          top,
          (width - other.width) as T,
          height,
        ),
        null,
      );
    }

    if (other.width == width) {
      // -----------
      // |  Other  |
      // |         |
      // -----------
      // |  ret    |
      // -----------
      return (
        Rectangle(
          left,
          (top + other.height) as T,
          width,
          (height - other.height) as T,
        ),
        null,
      );
    }
    // ------------------
    // |  Other  |   A  |
    // |         |      |
    // -----------......|
    // |       B        |
    // |                |
    // ------------------

    return (
      Rectangle(
        (left + other.width) as T,
        top,
        (width - other.width) as T,
        other.height,
      ), // A
      Rectangle(
        left,
        (top + other.height) as T,
        width,
        (height - other.height) as T,
      ), // B
    );
  }
}
