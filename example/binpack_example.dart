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

  // Target the max size 4096 x 4096
  final packer = Binpacker(4096, 4096);

  // and pack them
  packer.pack(rects);

  // The size we actually needed:
  print(packer.boundingBox());
  // Rectangle (0, 0) 560 x 400

  // Now get the list of placements
  print(packer.placements);
  // [
  //  (image4.png, Rectangle (0, 0) 300 x 400),
  //  (image1.png, Rectangle (300, 0) 100 x 200),
  //  (image3.png, Rectangle (400, 0) 128 x 100),
  //  (image2.png, Rectangle (528, 0) 32 x 64)
  // ]

  // If some rectangles didn't fit, you can get them
  print(packer.discards);

  // Print some stats
  print(packer.stats());
  // placed: 4 / 4, percent: 69.12%

  // If you don't know the target size, use
  final searchPacker = SearchBinpacker();
  searchPacker.pack(rects);

  // The size we actually needed:
  print(packer.stats());

  // and use the placements
  print(searchPacker.best!.placements);
}
