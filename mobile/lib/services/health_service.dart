import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  bool _isAuthorized = false;
  bool get isAuthorized => _isAuthorized;

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WORKOUT,
    HealthDataType.WATER,
  ];

  Future<bool> requestAuthorization() async {
    if (kIsWeb) return false;
    try {
      final permissions = _types.map((e) => HealthDataAccess.READ).toList();
      _isAuthorized = await _health.requestAuthorization(_types, permissions: permissions);
      return _isAuthorized;
    } catch (e) {
      debugPrint("Health Auth error: $e");
      return false;
    }
  }

  /// Ingests data written by Nothing X / CMF Watch app into Health Connect (Android) or Apple Health (iOS)
  Future<Map<String, dynamic>> fetchNothingXDailyMetrics(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    int totalSteps = 0;
    int sleepMinutes = 0;
    bool gymWorkoutDone = false;
    int waterIntakeMl = 0;

    if (kIsWeb) {
      // Web simulation for preview
      return {
        'steps': 10450,
        'sleepMinutes': 450,
        'gymWorkoutDone': true,
        'waterIntakeMl': 4500,
      };
    }

    try {
      final authorized = await requestAuthorization();
      if (!authorized) {
        return {
          'steps': totalSteps,
          'sleepMinutes': sleepMinutes,
          'gymWorkoutDone': gymWorkoutDone,
          'waterIntakeMl': waterIntakeMl,
        };
      }

      // Fetch steps
      final steps = await _health.getTotalStepsInInterval(startOfDay, endOfDay);
      totalSteps = steps ?? 0;

      // Fetch health data points
      final dataPoints = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startOfDay,
        endTime: endOfDay,
      );

      for (var point in dataPoints) {
        if (point.type == HealthDataType.SLEEP_ASLEEP || point.type == HealthDataType.SLEEP_SESSION) {
          final diff = point.dateTo.difference(point.dateFrom).inMinutes;
          sleepMinutes += diff;
        } else if (point.type == HealthDataType.WORKOUT) {
          gymWorkoutDone = true;
        } else if (point.type == HealthDataType.WATER) {
          final val = point.value;
          if (val is NumericHealthValue) {
            waterIntakeMl += (val.numericValue * 1000).toInt();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching Nothing X metrics: $e");
    }

    return {
      'steps': totalSteps,
      'sleepMinutes': sleepMinutes,
      'gymWorkoutDone': gymWorkoutDone,
      'waterIntakeMl': waterIntakeMl,
    };
  }
}
