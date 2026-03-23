// ignore_for_file: avoid_print // This is a benchmark.

import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:binpack/binpack.dart';
import 'package:collection/collection.dart';
import 'package:stats/stats.dart';

import '../test/binpack_test.dart';
import '../test/scenarios.dart';

/// Benchmark for SearchBinpacker.
class SearchBinpackerBenchmark extends BenchmarkBase {
  /// Create a new SearchBinpackerBenchmark.
  SearchBinpackerBenchmark() : super('SearchBinpackerBenchmark');

  // Real example shapes I had to pack
  final List<List<Rectangle<num>>> inputs = scenarios
      .map(
        (scenario) => scenario.entries
            .map(
              (e) => List<Rectangle<num>>.filled(
                e.value,
                rectangleFromString(e.key),
              ),
            )
            .expand((element) => element)
            .toList(),
      )
      .toList();

  final List<Result<int>> results = List<Result<int>>.filled(
    scenarios.length,
    const Result<int>(),
  );

  @override
  void run() {
    for (final e in inputs.indexed) {
      final input = e.$2;

      final result =
          SearchBinpacker<int>() //
              .pack(input.indexed.toList());

      final i = e.$1;
      results[i] = result;
    }
  }

  @override
  void report() {
    print('$name(RunTime): ${measure() / 1000000} seconds');

    final ratios = results.map((e) => e.ratio()).toList()..sort();
    final median = ratios.isEmpty
        ? 0.0
        : (ratios.length.isEven
              ? (ratios[ratios.length ~/ 2 - 1] + ratios[ratios.length ~/ 2]) /
                    2
              : ratios[ratios.length ~/ 2]);

    final stats = Stats.fromData(ratios);
    print('$name(Min Ratio): ${(stats.min * 100).toStringAsFixed(2)}%');
    print('$name(Max Ratio): ${(stats.max * 100).toStringAsFixed(2)}%');
    print('$name(Median Ratio): ${(median * 100).toStringAsFixed(2)}%');
    print('$name(Discards): ${results.map((e) => e.discards.length).sum}');
  }
}

void main() {
  SearchBinpackerBenchmark().report();
}
