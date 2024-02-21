// ignore_for_file: avoid_print

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:binpack/binpack.dart';
import 'package:stats/stats.dart';

import '../test/binpack_test.dart';
import '../test/scenarios.dart';

class SearchBinpackerBenchmark extends BenchmarkBase {
  SearchBinpackerBenchmark() : super('SearchBinpackerBenchmark');

  // Real example shapes I had to pack
  final inputs = scenarios.map(
    (scenario) {
      return scenario.entries
          .map((e) => List.filled(e.value, rectangleFromString(e.key)))
          .expand((element) => element)
          .toList();
    },
  ).toList();

  final ratios = List.filled(scenarios.length, 0.0);

  @override
  void run() {
    for (final e in inputs.indexed) {
      final input = e.$2;

      final results = SearchBinpacker() //
          .pack(input.indexed.toList());

      final i = e.$1;
      ratios[i] = results.ratio();
    }
  }

  @override
  void report() {
    print('$name(RunTime): ${measure() / 1000000} seconds');

    final stats = Stats.fromData(ratios);
    print('$name(Min Ratio): ${(stats.min * 100).toStringAsFixed(2)}%');
    print('$name(Max Ratio): ${(stats.max * 100).toStringAsFixed(2)}%');
    print('$name(Median Ratio): ${(stats.median * 100).toStringAsFixed(2)}%');
  }
}

void main() {
  SearchBinpackerBenchmark().report();
}
