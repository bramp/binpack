import 'dart:io';
import 'dart:math';

import 'package:binpack/binpack.dart';
import 'package:test/test.dart';

import 'scenarios.dart';

Rectangle<int> rectangleFromString(String size) {
  final parts = size.split('x');
  return Rectangle(0, 0, int.parse(parts[0]), int.parse(parts[1]));
}

void main() {
  final List<List<Rectangle<int>>> inputs = scenarios
      .map(
        (scenario) => scenario.entries
            .map((e) => List.filled(e.value, rectangleFromString(e.key)))
            .expand((element) => element)
            .toList(),
      )
      .toList();

  group('Binpacker().pack()', () {
    for (final s in inputs.indexed) {
      test('scenario ${s.$1}', () {
        final results = Binpacker(4096, 4096) //
            .pack(s.$2.indexed.toList());

        //print(packer.stats());
        final rects = results.discards.length + results.placements.length;
        expect(rects, equals(s.$2.length));

        //await placementToSVG(packer);
      });
    }
  });

  group('SearchBinpacker().pack()', () {
    for (final s in inputs.indexed) {
      test('scenario ${s.$1}', () async {
        final results = SearchBinpacker() //
            .pack(s.$2.indexed.toList());

        expect(results.discards, isEmpty);
        expect(results.placements.length, equals(s.$2.length));
        expect(results.ratio(), greaterThan(0.90));

        await placementToSVG(results, filename: 'test/scenario/${s.$1}.svg');
      });
    }
  });
}

/// Draws a SVG of the placements.
Future<dynamic> placementToSVG<K>(
  final Result results, {
  String filename = 'output.svg',
}) async {
  final f = File(filename);
  final w = f.openWrite();

  final bounds = results.boundingBox();

  w.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  w.writeln('<svg width="640"'
      ' viewBox="0 0 ${bounds.width} ${bounds.height}"'
      ' xmlns="http://www.w3.org/2000/svg">');

  w.writeln('  <rect'
      ' width="${bounds.width}" height="${bounds.height}"'
      ' x="0" y="0"'
      ' fill="black" />');

  final r = Random(0); // Seeded so we get the same sequence each time.
  for (final placement in results.placements) {
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
