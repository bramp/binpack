import 'dart:math';
import 'dart:io';

import 'package:binpack/binpack.dart';
import 'package:test/test.dart';

import 'scenarios.dart';

Rectangle rectangleFromString(String size) {
  final parts = size.split("x");
  return Rectangle(0, 0, int.parse(parts[0]), int.parse(parts[1]));
}

void main() {
  final List<List<Rectangle>> inputs = scenarios.map(
    (scenario) {
      return scenario.entries
          .map((e) => List.filled(e.value, rectangleFromString(e.key)))
          .expand((element) => element)
          .toList();
    },
  ).toList();

  group('Binpacker().pack()', () {
    for (final s in inputs.indexed) {
      test('scenario ${s.$1}', () {
        final packer = Binpacker(4096, 4096);
        packer.pack(s.$2.indexed.toList());

        //print(packer.stats());
        final rects = packer.discards.length + packer.placements.length;
        expect(rects, equals(s.$2.length));

        //await placementToSVG(packer);
      });
    }
  });

  group('SearchBinpacker().pack()', () {
    for (final s in inputs.indexed) {
      test('scenario ${s.$1}', () async {
        final packer = SearchBinpacker();
        packer.pack(s.$2.indexed.toList());

        expect(packer.best, isNotNull);
        expect(packer.best!.discards, isEmpty);
        expect(packer.best!.placements.length, equals(s.$2.length));
        expect(packer.best!.ratio(), greaterThan(0.90));

        await placementToSVG(packer.best!,
            filename: "test/scenario/${s.$1}.svg");
      });
    }
  });
}

/// Draws a SVG of the placements.
Future<dynamic> placementToSVG<K>(
  final Binpacker packer, {
  String filename = "output.svg",
}) async {
  final f = File(filename);
  final w = f.openWrite();

  final bounds = packer.boundingBox();

  w.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  w.writeln('<svg width="640"'
      ' viewBox="0 0 ${bounds.width} ${bounds.height}"'
      ' xmlns="http://www.w3.org/2000/svg">');

  w.writeln('  <rect'
      ' width="${bounds.width}" height="${bounds.height}"'
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
