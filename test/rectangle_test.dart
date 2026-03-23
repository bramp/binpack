import 'dart:math';

import 'package:binpack/src/rectangle.dart';
import 'package:test/test.dart';

void main() {
  group('Rectangle', () {
    test('area should return correct value', () {
      const rect = Rectangle(0, 0, 10, 20);
      expect(rect.area, 200);
    });

    test(
      'split should return empty list when other rectangle fits perfectly',
      () {
        const rect = Rectangle(1, 2, 10, 20);
        const other = Rectangle(0, 0, 10, 20);
        expect(rect.split(other), equals((null, null)));
      },
    );

    test('split should throw exception when other rectangle is larger', () {
      const rect = Rectangle(1, 2, 10, 20);
      expect(
        () => rect.split(const Rectangle(0, 0, 10, 30)),
        throwsA(isA<Exception>()),
      );
      expect(
        () => rect.split(const Rectangle(0, 0, 30, 20)),
        throwsA(isA<Exception>()),
      );
    });

    test('split: other rectangle fits perfectly along top', () {
      // -----------
      // |  Other  |
      // |         |
      // -----------
      // | expected|
      // -----------
      const rect = Rectangle(1, 2, 10, 20);
      const other = Rectangle(0, 0, 10, 5);
      const expected = (Rectangle(1, 7, 10, 15), null);

      expect(rect.area, other.area + expected.$1.area);

      final splits = rect.split(other);
      expect(splits, equals(expected));
    });

    test('split: other rectangle fits perfectly along side', () {
      const rect = Rectangle(1, 2, 20, 10);
      const other = Rectangle(0, 0, 5, 10);
      const expected = (Rectangle(6, 2, 15, 10), null);

      expect(rect.area, other.area + expected.$1.area);

      final splits = rect.split(other);
      expect(splits, equals(expected));
    });

    test('split: other rectangle fits imperfectly', () {
      // ------------------
      // |  Other  |   A  |
      // |         |      |
      // -----------......|
      // |       B        |
      // |                |
      // ------------------

      const rect = Rectangle(1, 2, 20, 30);
      const other = Rectangle(0, 0, 5, 10);

      const expected = (
        Rectangle(6, 2, 15, 10), //A
        Rectangle(1, 12, 20, 20), //B
      );

      expect(rect.area, other.area + expected.$1.area + expected.$2.area);

      final splits = rect.split(other);
      expect(splits, equals(expected));
    });
  });
}
