// ignore_for_file: avoid_print

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:binpack/binpack.dart';
import 'package:stats/stats.dart';

import '../test/binpack_test.dart';
import '../test/scenarios.dart';

class SearchBinpackerBenchmark extends BenchmarkBase {
  SearchBinpackerBenchmark() : super('SearchBinpackerBenchmark');

  // Real example shapes I had to pack
  final inputs = scenarios
      .map(
        (scenario) => scenario.entries
            .map((e) => List.filled(e.value, rectangleFromString(e.key)))
            .expand((element) => element)
            .toList(),
      )
      .toList();

  final results = List.filled(scenarios.length, const Result());

  @override
  void run() {
    for (final e in inputs.indexed) {
      final input = e.$2;

      final result = SearchBinpacker() //
          .pack(input.indexed.toList());

      final i = e.$1;
      results[i] = result;
    }
  }

  @override
  void report() {
    print('$name(RunTime): ${measure() / 1000000} seconds');

    final stats = Stats.fromData(results.map((e) => e.ratio()));
    print('$name(Min Ratio): ${(stats.min * 100).toStringAsFixed(2)}%');
    print('$name(Max Ratio): ${(stats.max * 100).toStringAsFixed(2)}%');
    print('$name(Median Ratio): ${(stats.median * 100).toStringAsFixed(2)}%');
    print('$name(Discards): ${results.map((e) => e.discards.length).sum}');
  }
}

void main() {
  SearchBinpackerBenchmark().report();
}
