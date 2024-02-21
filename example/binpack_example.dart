import 'dart:math';

import 'package:binpack/binpack.dart';

void main() {
  // Create a list of key and rectanges.
  // The key can be anything specific to your application.
  final rects = [
    ('image1.png', Rectangle(0, 0, 100, 200)), // Image 100x200 pixels
    ('image2.png', Rectangle(0, 0, 32, 64)),
    ('image3.png', Rectangle(0, 0, 128, 100)),
    ('image4.png', Rectangle(0, 0, 300, 400)),
  ];

  // Target the max size 4096 x 4096.
  var results = Binpacker(4096, 4096) //
      .pack(rects);

  // The size we actually needed (which may be smaller than 4096, 4096)
  print(results.boundingBox());
  // Rectangle (0, 0) 560 x 400

  // Now get the list of placements
  print(results.placements);
  // [
  //  (image4.png, Rectangle (0, 0) 300 x 400),
  //  (image1.png, Rectangle (300, 0) 100 x 200),
  //  (image3.png, Rectangle (400, 0) 128 x 100),
  //  (image2.png, Rectangle (528, 0) 32 x 64)
  // ]

  // If some rectangles didn't fit, you can get them
  print(results.discards);

  // Print some stats
  print(results.stats());
  // placed: 4 / 4, percent: 69.12%

  // If you don't know the target size, use SearchBinpacker. It will iteratively
  // try different target sizes, and return the optimal one.
  results = SearchBinpacker().pack(rects);

  // The size we actually needed:
  print(results.stats());

  // and use the placements
  print(results.placements);
}
