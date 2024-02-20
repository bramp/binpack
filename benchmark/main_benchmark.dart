import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:binpack/binpack.dart';

import '../test/binpack_test.dart';

// Create a new benchmark by extending BenchmarkBase
class BinarySearchBinpackerBenchmark extends BenchmarkBase {
  BinarySearchBinpackerBenchmark() : super('BinarySearchBinpackerBenchmark');

  // Real example shapes I had to pack
  final inputs = <Rectangle>[];

  // The benchmark code.
  @override
  void run() {
    final packer = SearchBinpacker();
    packer.pack(inputs.indexed.toList());
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
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
    inputSizes.map((key, value) => MapEntry(rectangleFromString(key), value));
    for (final e in inputSizes.entries) {
      final rect = rectangleFromString(e.key);

      for (var i = 0; i < e.value; i++) {
        inputs.add(rect);
      }
    }
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {}

  // To opt into the reporting the time per run() instead of per 10 run() calls.
  //@override
  //void exercise() => run();
}

void main() {
  BinarySearchBinpackerBenchmark().report();
}
