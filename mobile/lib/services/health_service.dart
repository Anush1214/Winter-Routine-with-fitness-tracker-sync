import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WORKOUT,
  ];

  Future<bool> requestPermissions() async {
    try {
      bool? hasPermissions = await _health.hasPermissions(_types);
      if (hasPermissions != true) {
        return await _health.requestAuthorization(_types);
      }
      return true;
    } catch (e) {
      debugPrint("Health permissions error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchDailyMetrics(DateTime date) async {
    final midnight = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    int totalSteps = 0;
    int sleepMinutes = 0;
    bool gymDone = false;

    try {
      final steps = await _health.getTotalStepsInInterval(midnight, endOfDay);
      totalSteps = steps ?? 0;

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED, HealthDataType.WORKOUT],
        startTime: midnight,
        endTime: endOfDay,
      );

      for (var point in healthData) {
        if (point.type == HealthDataType.SLEEP_ASLEEP || point.type == HealthDataType.SLEEP_IN_BED) {
          final diff = point.dateTo.difference(point.dateFrom).inMinutes;
          sleepMinutes += diff;
        } else if (point.type == HealthDataType.WORKOUT) {
          gymDone = true;
        }
      }
    } catch (e) {
      debugPrint("Error fetching health metrics: $e");
    }

    return {
      'steps': totalSteps,
      'sleepMinutes': sleepMinutes,
      'gymWorkoutDone': gymDone,
    };
  }
}
