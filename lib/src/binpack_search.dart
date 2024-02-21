import 'dart:math';

import 'package:binpack/binpack.dart';
import 'package:binpack/src/rectangle.dart';
import 'package:collection/collection.dart';

/// Packs a list of rectangles into the smallest possible space.
class SearchBinpacker<K> {
  /// Create a new SearchBinpacker.
  SearchBinpacker({this.searchAttempts = 100});
  Result<K> _best = const Result();

  /// How many different widths to try. The higher the number, the better the
  /// placements, but the slower the search.
  final int searchAttempts;

  Result<K> pack(List<(K, Rectangle)> inputs) {
    // Sort by height descending tends to produce good results
    // Make a copy so we don't modify the input.
    inputs = [...inputs]..sort((a, b) => compareByHeight(a.$2, b.$2));

    final maxWidth = inputs.map((e) => e.$2.width).max;
    final sumWidth = inputs.map((e) => e.$2.width).sum;
    final maxHeight = inputs.map((e) => e.$2.height).max;
    final sumHeight = inputs.map((e) => e.$2.height).sum;

    // Starting point
    // We can fit into a long rectange, that is the sum of the width, and max
    // of the heights. Effectively making a single row
    _best = Binpacker<K>(sumWidth, maxHeight) //
        .packInOrder(inputs);

    assert(_best.discards
        .isEmpty); // TODO Fix this, as it fails, if we sort by any other dimenion.

    num bestArea = _best.boundingBox().area;

    // Now we can search for the best packing
    //
    // The original https://github.com/TeamHypersomnia/rectpack2D implies this
    // can be done as a binary search, but I'm not sure how, since the ratio
    // does not monotonically increase. Instead we just try at uniform intervals.
    final interval = (sumWidth / searchAttempts).ceil();
    for (num width = maxWidth; width < sumWidth; width += interval) {
      final results = Binpacker<K>(width, sumHeight) //
          .packInOrder(inputs);

      // Since we allowed maxWidth * sumHeight we should always be able to fit
      // every square.
      assert(results.discards.isEmpty);

      final area = results.boundingBox().area;
      if (results.discards.isEmpty && area < bestArea) {
        _best = results;
        bestArea = area;
      }
    }

    return _best;
  }

  String stats() => _best.stats();
}
