import 'dart:developer' as developer;
import 'dart:io';

class PerformanceMetrics {
  static void displayMemoryUsage() {
    final processInfo = ProcessInfo.currentRss;
    developer.log('Memory Usage: $processInfo bytes');
  }

  static void displayPerformanceMetrics() {
    final stopwatch = Stopwatch()..start();
    // Perform some operations
    stopwatch.stop();
    developer.log('Execution Time: ${stopwatch.elapsedMilliseconds} ms');
  }

  static void measureMemoryUsageDuringRuntime() {
    final processInfo = ProcessInfo.currentRss;
    developer.log('Memory Usage During Runtime: $processInfo bytes');
  }

  static void calculateExecutionTime(Function block) {
    final stopwatch = Stopwatch()..start();
    block();
    stopwatch.stop();
    developer.log('Execution Time: ${stopwatch.elapsedMilliseconds} ms');
  }

  static void logPerformanceMetrics() {
    displayMemoryUsage();
    displayPerformanceMetrics();
  }
}
