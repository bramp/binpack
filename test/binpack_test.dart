import 'dart:math';
import 'dart:io';

import 'package:binpack/binpack.dart';
import 'package:test/test.dart';

Rectangle rectangleFromString(String size) {
  final parts = size.split("x");
  return Rectangle(0, 0, int.parse(parts[0]), int.parse(parts[1]));
}

void main() {
  // Real example shapes I had to pack
  final inputSizes = {
    "160x160": 2,
    "230x230": 11,
    "300x299": 1,
    "300x300": 290,
    "346x346": 2,
    "360x360": 12,
    "400x275": 1,
    "400x400": 4,
    "405x405": 1,
  };

  final inputs = <Rectangle>[];

  setUp(() {
    inputSizes.map((key, value) => MapEntry(rectangleFromString(key), value));
    for (final e in inputSizes.entries) {
      final rect = rectangleFromString(e.key);

      for (var i = 0; i < e.value; i++) {
        inputs.add(rect);
      }
    }
  });

  test('Binpacker().pack()', () async {
    final packer = Binpacker(4096, 4096);
    packer.pack(inputs.indexed.toList());

    print(packer.stats());
    // Placed: 158, Percent: 81.67505264282227%
    // Placed: 168, Percent: 94.10713315010071% (by area desc)
    // Placed: 168, Percent: 94.20905709266663% (by height desc)
    await placementToSVG(packer);
  });

  test('BinarySearchBinpacker().pack()', () async {
    final packer = SearchBinpacker();
    packer.pack(inputs.indexed.toList());

    print(packer.stats());
    await placementToSVG(packer.best!);
  });
}

/// Draws a SVG of the placements.
Future<dynamic> placementToSVG<K>(
  final Binpacker packer, {
  String filename = "output.svg",
}) async {
  final f = File(filename);
  final w = f.openWrite();

  w.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  w.writeln('<svg width="640"'
      ' viewBox="0 0 ${packer.width} ${packer.height}"'
      ' xmlns="http://www.w3.org/2000/svg">');

  w.writeln('  <rect'
      ' width="${packer.width}" height="${packer.height}"'
      ' x="0" y="0"'
      ' fill="black" />');

  final r = Random(0); // Seeded so we get the same sequence each time.
  for (final placement in packer.placements) {
    final rect = placement.$2;

    final hue = r.nextInt(360);
    w.writeln('  <rect name="${placement.$1}"'
        ' width="${rect.width}" height="${rect.height}"'
        ' x="${rect.left}" y="${rect.top}"'
        ' shape-rendering="crispEdges"'
        ' style="fill: hsl($hue, 100%, 50%);" />');
  }

  w.writeln('</svg>');

  await w.flush();
  return w.close();
}
