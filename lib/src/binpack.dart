import 'dart:collection';
import 'dart:math';

import 'package:binpack/src/rectangle.dart';
import 'package:collection/collection.dart';

/// A single item in the linked list of free spaces.
final class EntryItem extends LinkedListEntry<EntryItem> {
  /// Create a new EntryItem with a rectangle.
  EntryItem(this.rect);

  /// The free rectangle.
  final Rectangle rect;
}

/// The result of bin packing. Look at [discards] and [placements] for where
/// each rectangle ended up.
class Result<K> {
  /// Create a new Result with discards and placements.
  const Result({
    this.discards = const [],
    this.placements = const [],
  });

  /// The rectangles that didn't fit.
  final List<K> discards;

  /// The placements of the rectangles.
  final List<(K, Rectangle)> placements;

  /// Returns the smallest bounding box after packing. This will always be
  /// smaller or equal to the input dimensions.
  Rectangle<num> boundingBox() {
    if (placements.isEmpty) {
      return const Rectangle(0, 0, 0, 0);
    }

    final p = placements[0].$2;
    var minX = p.left;
    var maxX = p.right;
    var minY = p.top;
    var maxY = p.bottom;

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

  /// The percentage of space used in the min bounding box of all the
  /// placements.
  double ratio() {
    final usedArea = placements.fold<num>(0, (a, b) => a + b.$2.area);
    final bounds = boundingBox();

    return usedArea / bounds.area;
  }

  /// Returns a string with some stats about the packing.
  String stats() {
    final bounds = boundingBox();
    return '${bounds.width}x${bounds.height}'
        ' placed: ${placements.length} / '
        '${placements.length + discards.length},'
        ' percent: ${ratio() * 100}%';
  }
}

/// Packs a list of rectangles into a single larger space.
class Binpacker<K> {
  /// Create a new Binpacker with a max width and height.
  Binpacker(this.width, this.height) {
    // Add the entire space as a starting area.
    _free.add(EntryItem(Rectangle(0, 0, width, height)));
  }

  /// The max width
  final num width;

  /// The max height
  final num height;

  // Free is sorted by area, decending.
  // The smallest is area is thus always last, and hopefully the one we always
  // pop off.
  // This used to be a simple Array, but the insert/remove caused a lot of
  // copying. A linked list is faster, even if we can't do O(1) lookups and
  // binary searches.
  final LinkedList<EntryItem> _free = LinkedList<EntryItem>();

  /// The rectangles that didn't fit.
  final _discards = <K>[];

  /// The placements of the rectangles.
  final _placements = <(K, Rectangle)>[];

  /// Return the index of the smallest free Rectangle that will fit [rect].
  /// Returns -1 if no free space is found.
  EntryItem? _bestFitIndex(Rectangle rect) {
    // Search from the back (where the smallest rects are)
    for (EntryItem? i = _free.last; i != null; i = i.previous) {
      final f = i.rect;
      if (f.width >= rect.width && f.height >= rect.height) {
        return i;
      }
    }
    return null;
  }

  /// Returns the index where [element] should be in the [start] sorted list.
  /// Uses the area of the elements to make the decision.
  static EntryItem? _quickLowerBound(
    EntryItem? start,
    Rectangle element,
  ) {
    // Use a linear search
    final area = element.area;
    for (var i = start; i != null; i = i.next) {
      if (i.rect.area <= area) {
        return i;
      }
    }

    return null;
  }

  /// Pack the rectangles in to the space in the order they are given.
  /// As opposed to [pack], which may reorder the input to get a better packing.
  Result<K> packInOrder(Iterable<(K, Rectangle)> inputs) {
    final actualInputs = UnmodifiableListView(inputs);

    for (final input in actualInputs) {
      final key = input.$1;
      final rect = input.$2;
      final best = _bestFitIndex(rect);

      if (best == null) {
        // No free space
        _discards.add(key);
        continue;
      }

      // We can insert into this rect
      final freeRect = best.rect;

      // Place the input in the top left corner
      _placements.add((
        key,
        Rectangle(freeRect.left, freeRect.top, rect.width, rect.height),
      ));

      // Add the new splits.
      final (a, b) = freeRect.split(rect);

      // Do insertion sort.
      if (a != null) {
        final i = _quickLowerBound(best.next, a);
        //print("Insert a $i");
        if (i == null) {
          _free.add(EntryItem(a));
        } else {
          i.insertBefore(EntryItem(a));
        }
      }

      if (b != null) {
        assert(a != null, 'b set but a was not');

        final i = _quickLowerBound(best.next, b);
        //print("Insert b $i");
        if (i == null) {
          _free.add(EntryItem(b));
        } else {
          i.insertBefore(EntryItem(b));
        }
      }

      // Remove the rect we just split. We do this last, so we can
      // reference best in the quickLowerBound search.
      best.unlink();

      assert(
        _free.map((e) => e.rect).isSorted(compareByArea),
        'Free list must be sorted by area',
      );
    }

    return Result(
      discards: _discards,
      placements: _placements,
    );
  }

  /// Pack the rectangles in to the space, possibly after reordering.
  // TODO(bramp): Allow the sort order to be specified.
  Result<K> pack(
    List<(K, Rectangle)> inputs, {
    int Function(Rectangle a, Rectangle b)? sortBy,
  }) {
    for (final input in inputs) {
      if (input.$2.left != 0 || input.$2.top != 0) {
        throw Exception(
          'All rectangles must have left and top set to 0, '
          '${input.$1} does not.',
        );
      }
      if (input.$2.area <= 0) {
        throw Exception(
          'All rectangles must have a positive area, ${input.$1} does not.',
        );
      }
    }

    // Sort by height decending tends to produce good results
    // Make a copy so we don't modify the input.
    sortBy ??= compareByHeight;
    final sortedInputs = [...inputs]..sort((a, b) => sortBy!(a.$2, b.$2));

    return packInOrder(sortedInputs);
  }
}
