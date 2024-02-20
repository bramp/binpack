// TODO: Put public facing types in this file.

import 'dart:math';

import 'package:binpack/src/rectangle.dart';
import 'package:collection/collection.dart';

/// Packs a list of rectangles into a single larger space.
class Binpacker<K> {
  final num width;
  final num height;

  // Free is sorted by area, decending.
  // The smallest is area is thus always last, and hopefully the one we always
  // pop off.
  final List<Rectangle> free = [];
  final discards = <K>[];
  final placements = <(K, Rectangle)>[];

  Binpacker(this.width, this.height) {
    // Add the entire space as a starting area.
    free.add(Rectangle(0, 0, width, height));
  }

  /// Return the index of the smallest free Rectangle that will fit [rect].
  /// Returns -1 if no free space is found.
  int _bestFitIndex(Rectangle rect) {
    // Search from the back (where the smallest rects are)
    // This could be a binary search, but the list is small.
    for (var i = free.length - 1; i >= 0; i--) {
      if (free[i].width >= rect.width && free[i].height >= rect.height) {
        return i;
      }
    }
    return -1;
  }

  /// Pack the rectangles in to the space in the order they are given.
  /// As opposed to [pack], which may reorder the input to get a better packing.
  void packInOrder(List<(K, Rectangle)> inputs) {
    for (final input in inputs) {
      final key = input.$1;
      final rect = input.$2;
      final i = _bestFitIndex(rect);

      if (i == -1) {
        // No free space
        discards.add(key);
        continue;
      }

      // We can insert into this rect
      final freeRect = free.removeAt(i);
      //print("Delete $i from ${free.length}");

      // Place the input in the top left corner
      placements.add((
        key,
        Rectangle(freeRect.left, freeRect.top, rect.width, rect.height)
      ));

      // Add the new splits.
      final splits = freeRect.split(rect);

      // Do insertion sort.
      for (final s in splits) {
        final i = free.lowerBound(s, compareByArea);
        free.insert(i, s);
        //  //print(i);
      }
      //print(free.map((e) => e.area));
      assert(free.isSorted(compareByArea));

      // Brute force add and sort.
      //free.addAll(splits);
      //free.sort(compareByArea);
    }
  }

  /// Pack the rectangles in to the space, possibly after reordering.
  void pack(List<(K, Rectangle)> inputs) {
    for (final input in inputs) {
      if (input.$2.left != 0 || input.$2.top != 0) {
        throw Exception(
            "All rectangles must have left and top set to 0, ${input.$1} does not.");
      }
      if (input.$2.area <= 0) {
        throw Exception(
            "All rectangles must have a positive area, ${input.$1} does not.");
      }
    }

    // Sort by height decending tends to produce good results
    // Make a copy so we don't modify the input.
    inputs = [...inputs]..sort((a, b) => compareByHeight(a.$2, b.$2));

    packInOrder(inputs);
  }

  /// Returns the smallest bounding box after packing. This will always be smaller or equal
  /// to the input dimensions.
  Rectangle boundingBox() {
    if (placements.isEmpty) {
      return Rectangle(0, 0, 0, 0);
    }

    // The below is a faster version of this:
    //return placements.map((e) => e.$2).reduce((a, b) => a.boundingBox(b));

    final p = placements[0].$2;
    num minX = p.left, //
        maxX = p.right,
        minY = p.top,
        maxY = p.bottom;

    for (final p in placements) {
      final rect = p.$2;
      if (rect.left < minX) {
        minX = rect.left;
      }
      if (rect.right > maxX) {
        maxX = rect.right;
      }
      if (rect.top < minY) {
        minY = rect.top;
      }
      if (rect.bottom > maxY) {
        maxY = rect.bottom;
      }
    }

    return Rectangle(minX, minY, maxX - minX, maxY - minY);
  }

  /// The percentage of space used in the min bounding box of all the placements.
  double ratio() {
    final usedArea = placements.fold<num>(0, (a, b) => a + b.$2.area);

    final r = boundingBox();
    return usedArea / r.area;
  }

  String stats() {
    final box = boundingBox();
    return "${box.width}x${box.height} placed: ${placements.length} / ${placements.length + discards.length}, percent: ${ratio() * 100}%";
  }
}
