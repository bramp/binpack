import 'dart:math';

import 'package:binpack/binpack.dart';
import 'package:binpack/src/rectangle.dart';

/// Packs a list of rectangles into the smallest possible space.
class BinarySearchBinpacker<K> {
  Binpacker<K>? best;

  void pack(List<(K, Rectangle)> inputs) {
    // Sort by height decending tends to produce good results
    // Make a copy so we don't modify the input.
    inputs = [...inputs]..sort((a, b) => compareByHeight(a.$2, b.$2));

    var sumWidth = inputs.fold<num>(0, (a, b) => a + b.$2.width);
    var sumHeight = inputs.fold<num>(0, (a, b) => a + b.$2.height);
    var maxHeight = inputs.fold<num>(0, (a, b) => max(a, b.$2.height));

    // Starting point
    // We can fit into a long rectange, that is the sum of the width, and max
    // of the heights. Effectively making a single row
    best = Binpacker<K>(sumWidth, maxHeight);
    best!.packInOrder(inputs);
    assert(best!.discards
        .isEmpty); // TODO Fix this, as it fails, if we sort by any other dimenion.

    num bestArea = best!.boundingBox().area;

    // Now we can search for the best packing
    for (int x = 0; x < 100; x++) {
      //print("Trying ${(sumWidth / 100.0 * x).ceil()}");
      // TODO Something is broken, as not ever combo will fit :/
      final packer = Binpacker<K>((sumWidth / 100.0 * x).ceil(), sumHeight);
      packer.packInOrder(inputs);

      final area = packer.boundingBox().area;
      if (packer.discards.isEmpty && area < bestArea) {
        //print(best!.stats());
        best = packer;
        bestArea = area;
      }
    }
  }

  String stats() {
    return best!.stats();
  }
}
