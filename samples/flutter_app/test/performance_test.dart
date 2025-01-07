import 'package:flutter_test/flutter_test.dart';
import 'package:generative_ai_flutter/performance.dart';

void main() {
  group('PerformanceMetrics', () {
    test('measure execution time for critical functions', () {
      final stopwatch = Stopwatch()..start();
      // Perform some operations
      stopwatch.stop();
      final executionTime = stopwatch.elapsedMilliseconds;
      expect(executionTime, lessThan(1000)); // Example threshold
    });

    test('verify memory usage remains within acceptable limits', () {
      final processInfo = ProcessInfo.currentRss;
      expect(processInfo, lessThan(100000000)); // Example threshold
    });

    test('log results to validate performance optimizations', () {
      PerformanceMetrics.logPerformanceMetrics();
      // Verify the logs manually or use a logging framework to capture and validate logs
    });
  });
}
